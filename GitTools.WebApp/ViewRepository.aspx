﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ViewRepository.aspx.cs" Inherits="GitTools.WebApp.ViewRepository" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="Scripts/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="Scripts/jQuery.tmpl.min.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<h2 id="title"></h2>
<canvas id="canvas" width="120" height="100" style="margin-top:0px"></canvas>
<ul id="nodeList" style="list-style-type: none; font:16px/24px arial;"></ul>

<script id="nodeTemplate" type="text/x-jquery-tmpl"> 
<li>${Id} &nbsp; <span class="branch">${Branches}</span><span class="tag">${Tags}</span> <a href="#${Id}">${Message}</a></li>
</script>

<script type="text/javascript">
    var repo = '<%= Request["name"] %>';
    var ctx = $("#canvas")[0].getContext('2d'); ;
    var nodes;
    var links;

    $(function () {

        $("#title").text(repo);

        $.ajaxSetup({
            contentType: "application/json; charset=utf-8",
            dataType: "json"
        });

        $.ajax({
            url: "odata/RepositoryGraph('" + repo + "')/Nodes?$top=9&$orderby=Y",
            success: function (data) {
                nodes = data.d;
                $.ajax({
                    url: "odata/RepositoryGraph('" + repo + "')/Links",
                    success: function (data) {
                        links = data.d;
                        draw(nodes, links);
                    },
                    error: function (xhr) { alert(xhr.responseText); }
                });

            },
            error: function (xhr) { alert(xhr.responseText); }
        });


    });

    var h = 80;
    var w = 100;
    var r = 10;
    var xmax;

    function draw(nodes, links) {
        var ww = 0
        for (var i = 0; i < nodes.length; i++) {
            if (nodes[i].X > ww) ww = nodes[i].X;
        }
        ctx.canvas.width = xmax = nodes.length * w;
        ctx.canvas.height = (ww + 1.5) * h;
        drawLinks(links);
        drawNodes(nodes);
        $("#nodeTemplate").tmpl(nodes).appendTo("#nodeList");
    }

    function drawNodes(nodes) {

        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            var x = xmax - node.Y * w - w / 2;
            var y = node.X * h + h / 2;

            ctx.fillStyle = "#c3fac0";
            ctx.strokeStyle = "#336a3a";
            ctx.lineWidth = 5;

            ctx.beginPath();
            ctx.rect(x - 40, y - 25, 80, 50);

            ctx.stroke();
            ctx.fill();
            ctx.closePath();

            ctx.fillStyle = "#000";
            ctx.font = "16px Calibri";

            node.Id = node.Id.substring(0, 5);
            ctx.fillText(node.Id, x - 20, y + 5);

            ctx.fillText(node.Branches, x - 40, y + 45);
        }
    }


    function drawLinks(links) {

        ctx.lineWidth = 1;
        ctx.strokeStyle = "#808080";

        for (var i = 0; i < links.length; i++) {

            var link = links[i];
            var x1 = xmax - link.Y1 * w - w / 2;
            var y1 = link.X1 * h + h / 2;
            var x2 = xmax - link.Y2 * w - w / 2;
            var y2 = link.X2 * h + h / 2;
            var x3 = xmax - (link.Y2 - 1) * w - w / 2;

            if (link.X1 == link.X2) {
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
            }
            else {
                ctx.moveTo(x1, y1);
                ctx.lineTo(x3, y1);
                ctx.bezierCurveTo(x2, y1, x3, y2, x2, y2);
            }
            ctx.stroke();
        }
    }

</script>

</asp:Content>
