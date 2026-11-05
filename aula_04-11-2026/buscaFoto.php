<?php
$id = $_GET["id"];

$comando = "SELECT * FROM `fotos` WHERE `id` = $id";

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare($comando);
$sth->execute();

$resultado = $sth->fetch(PDO::FETCH_ASSOC);

if($resultado) {
    header('Content-Type: ' . mime_content_type($resultado["caminho"]));
    readfile($resultado["caminho"]);
} else {
    echo "Erro -> id nao encontrado";
}
?>
