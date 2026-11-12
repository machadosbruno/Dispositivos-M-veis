<?php
header('Content-Type: application/json; charset=utf-8');

$usuarioAtual = $_GET['usuario_id'];
$coringa = '%' . $_GET['termo'] . '%';

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("
    SELECT
        u.id,
        u.nome,
        COALESCE(
            (SELECT a.status FROM solicitacoes_amizade a
             WHERE a.solicitante_id = :usuario_atual AND a.solicitado_id = u.id),
            (SELECT a.status FROM solicitacoes_amizade a
             WHERE a.solicitado_id = :usuario_atual AND a.solicitante_id = u.id),
            'NENHUM'
        ) AS status_amizade,
        EXISTS(
            SELECT 1 FROM solicitacoes_amizade a
            WHERE a.solicitante_id = :usuario_atual AND a.solicitado_id = u.id
        ) AS pedido_meu
    FROM `usuarios` u
    WHERE u.id != :usuario_atual AND u.nome LIKE :termo
    ORDER BY u.nome ASC
");
$sth->execute(['usuario_atual' => $usuarioAtual, 'termo' => $coringa]);
$usuarios = $sth->fetchAll(PDO::FETCH_ASSOC);

$sth = $dbh->prepare("
    SELECT
        p.id,
        p.usuario_id,
        u.nome AS autor,
        p.texto,
        p.caminho,
        (SELECT COUNT(*) FROM curtidas c WHERE c.postagem_id = p.id) AS curtidas,
        EXISTS(
            SELECT 1 FROM curtidas c
            WHERE c.postagem_id = p.id AND c.usuario_id = :usuario_atual
        ) AS curtida_do_usuario,
        (
            p.usuario_id = :usuario_atual OR EXISTS(
                SELECT 1 FROM solicitacoes_amizade a
                WHERE a.status = 'ACEITO'
                  AND (
                      (a.solicitante_id = :usuario_atual AND a.solicitado_id = p.usuario_id)
                      OR (a.solicitado_id = :usuario_atual AND a.solicitante_id = p.usuario_id)
                  )
            )
        ) AS pode_comentar
    FROM `postagens` p
    LEFT JOIN `usuarios` u ON u.id = p.usuario_id
    WHERE p.texto LIKE :termo
    ORDER BY p.id DESC
");
$sth->execute(['usuario_atual' => $usuarioAtual, 'termo' => $coringa]);
$postagens = $sth->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['usuarios' => $usuarios, 'postagens' => $postagens]);
?>
