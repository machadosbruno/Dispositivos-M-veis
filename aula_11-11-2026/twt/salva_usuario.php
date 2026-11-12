<?php
header('Content-Type: application/json; charset=utf-8');

$n = $_GET['nome'];
$e = $_GET['email'];
$s = $_GET['senha'];

$comandoSQL = "INSERT INTO `usuarios` (`id`, `nome`, `email`, `senha`) VALUES (NULL, '$n', '$e', '$s')";

$dsn = 'mysql:dbname=twt;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$resultado = $dbh->query($comandoSQL);

if($resultado) {
    echo json_encode(['resposta' => 'Usuário cadastrado!', 'id' => "{$dbh->lastInsertId()}"]);
    // echo "Texto salvo!";
} else {
    echo json_encode(['erro' => 'Erro no cadastro!']);
}
?>