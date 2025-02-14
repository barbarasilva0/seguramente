<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    // Conexão com os Bancos de Dados
    Connection connJogos = null;
    Connection connUtilizadores = null;
    Statement stmtJogos = null;
    Statement stmtUtilizadores = null;
    ResultSet rs = null;

    // Obtendo ID do Quiz a partir da URL
    String idJogo = request.getParameter("id");
    String tituloQuiz = "Quiz Desconhecido";
    String descricaoQuiz = "Descrição não disponível.";
    String dataCriacao = "Data não encontrada";
    String criadoPor = "Desconhecido";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connJogos = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_jogos", "root", "!5xne5Qui8900");
        connUtilizadores = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_utilizadores", "root", "!5xne5Qui8900");
        
        stmtJogos = connJogos.createStatement();
        stmtUtilizadores = connUtilizadores.createStatement();

        // Consulta para obter informações do quiz
        String query = "SELECT J.Nome, J.Descricao, J.Data_Criacao, J.Criado_por, U.Nome AS Criador " +
                       "FROM Jogo J LEFT JOIN segura_utilizadores.Utilizador U ON J.Criado_por = U.ID_Utilizador " +
                       "WHERE J.ID_Jogo = " + idJogo;
        rs = stmtJogos.executeQuery(query);

        if (rs.next()) {
            tituloQuiz = rs.getString("Nome");
            descricaoQuiz = rs.getString("Descricao");
            dataCriacao = rs.getString("Data_Criacao");
            criadoPor = rs.getString("Criador") != null ? rs.getString("Criador") : "Desconhecido";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); if (stmtJogos != null) stmtJogos.close(); if (stmtUtilizadores != null) stmtUtilizadores.close(); if (connJogos != null) connJogos.close(); if (connUtilizadores != null) connUtilizadores.close(); } catch (Exception e) { e.printStackTrace(); }
    }
%>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= tituloQuiz %> - SeguraMente</title>
    <link rel="stylesheet" href="html/css/jogar_quizz.css">
</head>
<body>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <h1>SeguraMente</h1>
            <a href="dashboard.jsp" class="sidebar-item">
                <img src="html/imagens/jogos_disponiveis_icon.png" alt="Jogos Disponíveis" style="width: 20px; height: 20px;">
                Jogos Disponíveis
            </a>
            <a href="missoes_semanais.jsp" class="sidebar-item">
                <img src="html/imagens/missoes_icon.png" alt="Missões Semanais" style="width: 20px; height: 20px;">
                Missões Semanais
            </a>
            <a href="historico.jsp" class="sidebar-item">
                <img src="html/imagens/historico_icon.png" alt="Histórico" style="width: 20px; height: 20px;">
                Histórico
            </a>
            <a href="#" class="sidebar-item" id="logout">
                <img src="html/imagens/logout_icon.png" alt="Sair" style="width: 20px; height: 20px;">
                Sair
            </a>
        </div>

        <!-- Content -->
        <div class="content">
            <!-- Header -->
            <div class="header">
                <div class="search-container">
                    <img src="html/imagens/lupa.png" alt="Lupa" class="search-icon">
                    <input type="text" placeholder="Pesquisar...">
                </div>
                <a href="criar_quizz.jsp" class="create-quiz">Criar Quizz</a>
                <a href="perfil.jsp" class="profile">
                    <img src="html/imagens/avatar.png" alt="Avatar">
                    <span>Pessoa</span>
                </a>
            </div>

            <!-- Quiz -->
            <div class="quiz-container">
                <div class="quiz-image">
                    <img src="html/imagens/quiz-image.png" alt="<%= tituloQuiz %>">
                    <div>
                        <div class="quiz-info">
                            <p>Data: <%= dataCriacao %></p>
                            <p>Pontos: 80 pontos</p>
                            <p>Criado por: <%= criadoPor %></p>
                        </div>
                        <div class="quiz-button">
                            <button id="start-quiz-btn">Começar o Quiz</button>
                        </div>
                    </div>
                </div>

                <div class="quiz-details">
                    <h2><%= tituloQuiz %></h2>
                    <p><%= descricaoQuiz %></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Escolha -->
    <div class="modal-overlay" id="quiz-mode-modal">
        <div class="modal-content">
            <h2>Como deseja jogar?</h2>
            <div class="modal-buttons">
                <button class="btn-solo" id="play-solo">Jogar Sozinho</button>
                <button class="btn-multi" id="play-multi">Jogar com Outros</button>
                <button class="btn-cancel" id="cancel-quiz">Cancelar</button>
            </div>
        </div>
    </div>

    <!-- Modal de Logout -->
    <div class="modal-overlay" id="logout-modal">
        <div class="modal-content">
            <h2>Tem certeza que deseja sair?</h2>
            <div class="modal-buttons">
                <button class="btn-solo" id="confirmYes">Sim</button>
                <button class="btn-cancel" id="confirmNo">Não</button>
            </div>
        </div>
    </div>

    <script>
        const logoutLink = document.getElementById('logout');
        const logoutModal = document.getElementById('logout-modal');
        const confirmYes = document.getElementById('confirmYes');
        const confirmNo = document.getElementById('confirmNo');
        const startQuizBtn = document.getElementById('start-quiz-btn');
        const quizModeModal = document.getElementById('quiz-mode-modal');
        const playSoloBtn = document.getElementById('play-solo');
        const playMultiBtn = document.getElementById('play-multi');
        const cancelQuizBtn = document.getElementById('cancel-quiz');

        // Modal de Logout
        logoutLink.addEventListener('click', (e) => {
            e.preventDefault();
            logoutModal.classList.add('show');
        });

        confirmYes.addEventListener('click', () => {
            window.location.href = '../index.html';
        });

        confirmNo.addEventListener('click', () => {
            logoutModal.classList.remove('show');
        });

        // Modal de Escolha do Modo de Jogo
        startQuizBtn.addEventListener('click', () => {
            quizModeModal.classList.add('show');
        });

        playSoloBtn.addEventListener('click', () => {
            window.location.href = 'quizz.jsp?id=<%= idJogo %>';
        });

        playMultiBtn.addEventListener('click', () => {
            window.location.href = 'lobby.jsp?id=<%= idJogo %>';
        });

        cancelQuizBtn.addEventListener('click', () => {
            quizModeModal.classList.remove('show');
        });
    </script>
</body>
</html>
