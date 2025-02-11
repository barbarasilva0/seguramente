<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
	// Conexão com o Banco de Dados
	String url = "jdbc:mysql://localhost:3306/segura";
	String user = "root"; // Substituir pelo usuário real do MySQL
	String password = "!5xne5Qui8900"; // Substituir pela senha real do MySQL
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
    int quizzesCompletados = 0;

    // Verificação de sessão do usuário
    HttpSession sessao = request.getSession();
    String nomeUsuario = (String) sessao.getAttribute("nomeUsuario");
    int idUsuario = (sessao.getAttribute("idUsuario") != null) ? (int) sessao.getAttribute("idUsuario") : 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);
        stmt = conn.createStatement();

        // Contar quizzes completados pelo usuário
        if (idUsuario > 0) {
            String countQuery = "SELECT COUNT(*) AS total FROM Historico WHERE ID_Utilizador = " + idUsuario + " AND Estado = 'Completado'";
            ResultSet rsCount = stmt.executeQuery(countQuery);
            if (rsCount.next()) {
                quizzesCompletados = rsCount.getInt("total");
            }
            rsCount.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - SeguraMente</title>
    <link rel="stylesheet" href="html/css/dashboard.css">
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
            <a href="logout.jsp" class="sidebar-item">
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
                    <span><%= (nomeUsuario != null) ? nomeUsuario : "Visitante" %></span>
                </a>
            </div>

            <!-- Quiz Section -->
            <div class="quiz-section">
                <div class="quiz-header">
                    <div class="user-info">
                        <img src="html/imagens/avatar.png" alt="Avatar do usuário" class="user-avatar">
                        <div class="user-details">
                            <span class="user-name"><%= (nomeUsuario != null) ? nomeUsuario : "Convidado" %></span>
                            <div class="user-score-container">
                                <img src="html/imagens/flag_icon.png" alt="Flag Icon" class="flag-icon">
                                <div class="user-score">
                                    <span class="score-value"><%= quizzesCompletados %></span>
                                    <span class="score-text">Quiz Passed</span>
                                </div>
                            </div>
                        </div>                                            
                    </div>
                </div>

                <a href="jogar_agora_registado.jsp" class="play-now-button">Jogar Agora</a>

                <!-- Listagem dinâmica dos quizzes -->
                <%
                    try {
                        rs = stmt.executeQuery("SELECT ID_Jogo, Nome, Descricao FROM Jogo");
                        while (rs.next()) {
                %>
                <div class="quiz-card">
                    <img src="html/imagens/quiz-image.png" alt="Quiz">
                    <div class="quiz-content">
                        <div class="quiz-title"><%= rs.getString("Nome") %></div>
                        <div class="quiz-description">
                            <%= rs.getString("Descricao") %>
                        </div>
                        <a href="jogar_quizz.jsp?id=<%= rs.getInt("ID_Jogo") %>" class="quiz-button">Jogar</a>
                    </div>
                </div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (rs != null) rs.close(); if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
                    }
                %>
            </div>
        </div>
    </div>
</body>
</html>
