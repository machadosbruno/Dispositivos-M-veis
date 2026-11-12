<?php
header('Content-Type: application/json; charset=utf-8');

$postagemId = $_GET['postagem_id'];
$usuarioId = $_GET['usuario_id'];
$texto = $_GET['texto'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("
    SELECT
        p.usuario_id,
        (
            p.usuario_id = :usuario_id OR EXISTS(
                SELECT 1 FROM solicitacoes_amizade a
                WHERE a.status = 'ACEITO'
                  AND (
                      (a.solicitante_id = :usuario_id AND a.solicitado_id = p.usuario_id)
                      OR (a.solicitado_id = :usuario_id AND a.solicitante_id = p.usuario_id)
                  )
            )
        ) AS pode_comentar
    FROM `postagens` p
    WHERE p.id = :postagem_id
");
$sth->execute(['postagem_id' => $postagemId, 'usuario_id' => $usuarioId]);
$postagem = $sth->fetch(PDO::FETCH_ASSOC);

if (!$postagem || !$postagem['pode_comentar']) {
    echo json_encode(['erro' => 'Voce so pode comentar em postagens de amigos.']);
    exit;
}

$sth = $dbh->prepare(
    "INSERT INTO `comentarios` (`id`, `postagem_id`, `usuario_id`, `texto`) VALUES (NULL, :postagem_id, :usuario_id, :texto)"
);
$resultado = $sth->execute([
    'postagem_id' => $postagemId,
    'usuario_id' => $usuarioId,
    'texto' => $texto,
]);

if ($resultado) {
    echo json_encode(['resposta' => 'Comentario salvo!', 'id' => $dbh->lastInsertId()]);
} else {
    echo json_encode(['erro' => 'Erro ao salvar comentario.']);
}
?>
