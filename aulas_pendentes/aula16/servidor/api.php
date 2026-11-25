<?php
// API única da aula 16. O app chama api.php?acao=...
// Atenção: para simplificar, o app envia usuario_id e o servidor confia nele (sem token),
// mas o perfil é sempre conferido no banco.
header('Content-Type: application/json');

$banco = new mysqli('localhost', 'root', '', 'aula16'); // ajuste usuário e senha
$banco->set_charset('utf8mb4');

$acao = $_REQUEST['acao'] ?? '';
$usuario = (int) ($_REQUEST['usuario_id'] ?? 0);

function erro($codigo, $mensagem)
{
    http_response_code($codigo);
    echo json_encode(['erro' => $mensagem]);
    exit;
}

function consulta($sql, $tipos = '', ...$params)
{
    global $banco;
    $cmd = $banco->prepare($sql);
    if ($tipos != '') {
        $cmd->bind_param($tipos, ...$params);
    }
    $cmd->execute();
    return $cmd;
}

// erro 403 se o usuário não tem o perfil exigido
function exigePerfil($perfil)
{
    global $usuario;
    $u = consulta('SELECT perfil FROM usuarios WHERE id = ?', 'i', $usuario)->get_result()->fetch_assoc();
    if (!$u || $u['perfil'] != $perfil) {
        erro(403, 'acesso exclusivo do perfil ' . $perfil);
    }
}

function comissaoAtual()
{
    $r = consulta('SELECT comissao FROM config WHERE id = 1')->get_result()->fetch_assoc();
    return (float) $r['comissao'];
}

if ($acao == 'cadastro') {
    $nome = $_POST['nome'] ?? '';
    $email = $_POST['email'] ?? '';
    $senha = $_POST['senha'] ?? '';
    $perfil = $_POST['perfil'] ?? '';
    if ($nome == '' || $email == '' || $senha == '') {
        erro(400, 'preencha todos os campos');
    }
    // gerente não pode se cadastrar pelo app
    if ($perfil != 'produtor' && $perfil != 'vendedor') {
        erro(400, 'perfil inválido');
    }
    $hash = password_hash($senha, PASSWORD_DEFAULT);
    try {
        consulta('INSERT INTO usuarios (nome, email, senha, perfil) VALUES (?, ?, ?, ?)', 'ssss', $nome, $email, $hash, $perfil);
    } catch (mysqli_sql_exception $e) {
        erro(409, 'e-mail já cadastrado');
    }
    echo json_encode(['id' => $banco->insert_id, 'perfil' => $perfil]);

} elseif ($acao == 'login') {
    $email = $_POST['email'] ?? '';
    $senha = $_POST['senha'] ?? '';
    $u = consulta('SELECT id, perfil, senha FROM usuarios WHERE email = ?', 's', $email)->get_result()->fetch_assoc();
    if (!$u || !password_verify($senha, $u['senha'])) {
        erro(401, 'e-mail ou senha incorretos');
    }
    echo json_encode(['id' => (int) $u['id'], 'perfil' => $u['perfil']]);

} elseif ($acao == 'comissao') {
    echo json_encode(['comissao' => comissaoAtual()]);

} elseif ($acao == 'produzir') {
    exigePerfil('produtor');
    $quantidade = (int) ($_POST['quantidade'] ?? 0);
    $valor = (float) ($_POST['valor_unitario'] ?? 0);
    if ($quantidade <= 0 || $valor <= 0) {
        erro(400, 'quantidade e valor devem ser positivos');
    }
    consulta('INSERT INTO producoes (produtor_id, quantidade, estoque, valor_unitario) VALUES (?, ?, ?, ?)',
        'iiid', $usuario, $quantidade, $quantidade, $valor);
    $total = $quantidade * $valor;
    $comissao = comissaoAtual();
    echo json_encode([
        'comissao' => $comissao,
        'total_antes' => round($total, 2),
        'total_depois' => round($total * (1 - $comissao / 100), 2),
    ]);

} elseif ($acao == 'producoes') {
    exigePerfil('vendedor');
    $r = consulta(
        'SELECT p.id, u.nome AS produtor, p.estoque, p.valor_unitario
         FROM producoes p JOIN usuarios u ON u.id = p.produtor_id
         WHERE p.estoque > 0 ORDER BY p.id'
    )->get_result()->fetch_all(MYSQLI_ASSOC);
    echo json_encode($r);

} elseif ($acao == 'comprar') {
    exigePerfil('vendedor');
    $producao = (int) ($_POST['producao_id'] ?? 0);
    $quantidade = (int) ($_POST['quantidade'] ?? 0);
    if ($quantidade <= 0) {
        erro(400, 'quantidade inválida');
    }
    $banco->begin_transaction();
    $p = consulta('SELECT estoque, valor_unitario FROM producoes WHERE id = ? FOR UPDATE', 'i', $producao)
        ->get_result()->fetch_assoc();
    if (!$p || $p['estoque'] < $quantidade) {
        $banco->rollback();
        erro(400, 'estoque insuficiente');
    }
    $comissao = comissaoAtual(); // percentual gravado na venda
    $total = $quantidade * (float) $p['valor_unitario'];
    $valorComissao = round($total * $comissao / 100, 2);
    consulta('UPDATE producoes SET estoque = estoque - ? WHERE id = ?', 'ii', $quantidade, $producao);
    consulta(
        'INSERT INTO vendas (producao_id, vendedor_id, quantidade, valor_total, comissao_percentual, valor_comissao, data)
         VALUES (?, ?, ?, ?, ?, ?, NOW())',
        'iiiddd', $producao, $usuario, $quantidade, $total, $comissao, $valorComissao
    );
    $banco->commit();
    echo json_encode([
        'quantidade' => $quantidade,
        'valor_unitario' => (float) $p['valor_unitario'],
        'valor_total' => round($total, 2),
        'comissao' => $comissao,
        'valor_comissao' => $valorComissao,
        'valor_produtor' => round($total - $valorComissao, 2),
    ]);

} elseif ($acao == 'resumo') {
    exigePerfil('gerente');
    $gerou = consulta('SELECT COALESCE(SUM(quantidade), 0) AS t FROM producoes')->get_result()->fetch_assoc()['t'];
    $vendeu = consulta('SELECT COALESCE(SUM(quantidade), 0) AS t FROM vendas')->get_result()->fetch_assoc()['t'];
    $lucro = consulta(
        'SELECT COALESCE(SUM(valor_comissao), 0) AS t FROM vendas
         WHERE YEAR(data) = YEAR(NOW()) AND MONTH(data) = MONTH(NOW())'
    )->get_result()->fetch_assoc()['t'];
    echo json_encode([
        'total_gerado' => (int) $gerou,
        'total_vendido' => (int) $vendeu,
        'lucro_mes' => (float) $lucro,
        'comissao' => comissaoAtual(),
    ]);

} elseif ($acao == 'definir_comissao') {
    exigePerfil('gerente');
    $comissao = (float) ($_POST['comissao'] ?? -1);
    if ($comissao < 0 || $comissao > 100) {
        erro(400, 'percentual deve estar entre 0 e 100');
    }
    consulta('UPDATE config SET comissao = ? WHERE id = 1', 'd', $comissao);
    echo json_encode(['comissao' => $comissao]);

} else {
    erro(400, 'ação desconhecida');
}
