<?php
date_default_timezone_set('America/Sao_Paulo');

$id = $_POST['id'] ?? '';
$dia = $_POST['dia'] ?? '';             // aaaa-mm-dd
$titulo = trim($_POST['titulo'] ?? '');
$descricao = trim($_POST['descricao'] ?? '');

// mesmas regras do salvaAtividade.php
if ($titulo === '') {
    echo "Erro -> informe o titulo";
    exit;
}

$data = DateTime::createFromFormat('!Y-m-d', $dia);
if (!$data || $data->format('Y-m-d') !== $dia) {
    echo "Erro -> data invalida";
    exit;
}
if ($dia > date('Y-m-d')) {
    echo "Erro -> a data nao pode ser futura";
    exit;
}

$dsn = 'mysql:dbname=atividades_dia;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare(
    "UPDATE `atividades` SET dia = :dia, titulo = :titulo, descricao = :descricao WHERE id = :id"
);
$resultado = $sth->execute([
    'id' => $id,
    'dia' => $dia,
    'titulo' => mb_substr($titulo, 0, 100),
    'descricao' => $descricao === '' ? null : mb_substr($descricao, 0, 200),
]);

if($resultado) {
    echo "Atividade alterada!";
} else {
    echo "Erro -> nao foi possivel alterar";
}
?>
