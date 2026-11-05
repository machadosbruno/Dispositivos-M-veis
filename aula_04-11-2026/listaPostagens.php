<?php
header('Content-Type: application/json; charset=utf-8');

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("SELECT * FROM `postagens`");
$sth->execute();

$resultado = $sth->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($resultado);
?>
