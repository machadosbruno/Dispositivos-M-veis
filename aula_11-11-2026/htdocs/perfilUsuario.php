<?php
header('Content-Type: application/json; charset=utf-8');

$usuarioAtual = $_GET['usuario_atual'];
$usuarioId = $_GET['usuario_id'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("SELECT id, nome FROM `usuarios` WHERE id = :id");
$sth->execute(['id' => $usuarioId]);
$usuario = $sth->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    echo json_encode(['erro' => 'Usuario nao encontrado.']);
    exit;
}

$sth = $dbh->prepare("
    SELECT id, status, solicitante_id
    FROM `solicitacoes_amizade`
    WHERE (solicitante_id = :usuario_atual AND solicitado_id = :usuario_id)
       OR (solicitado_id = :usuario_atual AND solicitante_id = :usuario_id)
");
$sth->execute(['usuario_atual' => $usuarioAtual, 'usuario_id' => $usuarioId]);
$solicitacao = $sth->fetch(PDO::FETCH_ASSOC);

echo json_encode([
    'id' => $usuario['id'],
    'nome' => $usuario['nome'],
    'status_amizade' => $solicitacao ? $solicitacao['status'] : 'NENHUM',
    'pedido_meu' => $solicitacao ? ($solicitacao['solicitante_id'] == $usuarioAtual) : false,
    'solicitacao_id' => $solicitacao ? $solicitacao['id'] : null,
]);
?>
