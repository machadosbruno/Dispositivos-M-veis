<?php
header('Content-Type: application/json; charset=utf-8');

$id = $_GET['id'];
$status = $_GET['status']; // 'ACEITO' ou 'REJEITADO'

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("UPDATE `solicitacoes_amizade` SET status = :status WHERE id = :id");
$resultado = $sth->execute(['status' => $status, 'id' => $id]);

if ($resultado) {
    echo json_encode(['resposta' => 'Solicitacao atualizada!']);
} else {
    echo json_encode(['erro' => 'Erro ao atualizar solicitacao.']);
}
?>
