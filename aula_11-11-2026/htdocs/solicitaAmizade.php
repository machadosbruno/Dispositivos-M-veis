<?php
header('Content-Type: application/json; charset=utf-8');

$solicitanteId = $_GET['solicitante_id'];
$solicitadoId = $_GET['solicitado_id'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare(
    "SELECT id, status FROM `solicitacoes_amizade` WHERE solicitante_id = :solicitante_id AND solicitado_id = :solicitado_id"
);
$sth->execute(['solicitante_id' => $solicitanteId, 'solicitado_id' => $solicitadoId]);
$existente = $sth->fetch(PDO::FETCH_ASSOC);

if ($existente) {
    if ($existente['status'] === 'REJEITADO') {
        $sth = $dbh->prepare(
            "UPDATE `solicitacoes_amizade` SET status = 'PENDENTE' WHERE id = :id"
        );
        $sth->execute(['id' => $existente['id']]);
    }
    echo json_encode(['resposta' => 'Solicitacao de amizade enviada!']);
    exit;
}

$sth = $dbh->prepare(
    "INSERT INTO `solicitacoes_amizade` (`id`, `solicitante_id`, `solicitado_id`, `status`) VALUES (NULL, :solicitante_id, :solicitado_id, 'PENDENTE')"
);
$resultado = $sth->execute(['solicitante_id' => $solicitanteId, 'solicitado_id' => $solicitadoId]);

if ($resultado) {
    echo json_encode(['resposta' => 'Solicitacao de amizade enviada!']);
} else {
    echo json_encode(['erro' => 'Erro ao solicitar amizade.']);
}
?>
