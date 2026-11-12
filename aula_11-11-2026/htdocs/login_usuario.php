<?php
header('Content-Type: application/json; charset=utf-8');

$e = $_GET['email'];
$s = $_GET['senha'];

$comandoSQL = "SELECT * FROM `usuarios` WHERE `email` = '$e' AND `senha` = '$s'";

$dsn = 'mysql:dbname=bancobruno;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare($comandoSQL);
$sth->execute();

$resultado = $sth->fetch(PDO::FETCH_ASSOC);

if($resultado) {
    echo json_encode([
        'resposta' => 'Login efetuado!',
        'id' => $resultado['id'],
        'nome' => $resultado['nome'],
    ]);
} else {
    echo json_encode(['erro' => 'E-mail ou senha inválidos!']);
}
?>
