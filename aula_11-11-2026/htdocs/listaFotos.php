<?php
header('Content-Type: application/json; charset=utf-8');

$comando = "SELECT * FROM `fotos`";

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare($comando);
$sth->execute();

$resultado = $sth->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($resultado);
?>
