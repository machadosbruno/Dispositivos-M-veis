<?php
$id = $_POST['id'] ?? '';

$dsn = 'mysql:dbname=atividades_dia;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("DELETE FROM `atividades` WHERE id = :id");
$resultado = $sth->execute(['id' => $id]);

if($resultado && $sth->rowCount() > 0) {
    echo "Atividade excluída!";
} else {
    echo "Erro -> nao foi possivel excluir";
}
?>
