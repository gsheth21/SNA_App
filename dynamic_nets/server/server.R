source(here::here("shared", "helpers", "ui_helpers.R"))

server <- function(input, output, session) {

  # ── Tab routing ───────────────────────────────────────────────────────────

  current_tab <- reactiveVal("stats")

  observeEvent(input$current_tab, {
    req(input$current_tab)
    current_tab(input$current_tab)
  }, ignoreNULL = TRUE, ignoreInit = FALSE)

  output$tab_content <- renderUI({
    switch(current_tab(),
      stats     = tab_stats,
      snapshots = tab_snapshots,
      multitime = tab_multitime,
      animation = tab_animation,
      dataset_info = tags$div(
        id = "tab-dataset_info", class = "tab-inner",
        fluidRow(
          box(
            title       = tagList(icon("database"), " Fraternity Social Networks (Longitudinal)"),
            width       = 12,
            solidHeader = TRUE,
            status      = "primary",
            h4("Newcomb's College Fraternity Longitudinal Networks", style = "margin-top: 0; color: #CC0000;"),
            hr(),
            h5("Background"),
            p("Theodore Newcomb's classic longitudinal study tracked social preferences among 17 members of a small
              college fraternity throughout a single academic year (1950s). Each week, members ranked their peers on
              who they \u201cliked most.\u201d These rankings were converted into directed sociometric networks by retaining
              each member's top choices as edges. The data captures the formation and stabilization of friendship
              structures over time, making it a foundational dataset for dynamic network analysis and social influence research."),
            p("Wave frat9 is absent from the original data; all other weekly snapshots (frat0\u2013frat15) are included."),
            hr(),
            h5("Network Structure"),
            tags$table(
              class = "table table-condensed",
              style = "font-size: 13px; margin-bottom: 8px; width: auto;",
              tags$tbody(
                tags$tr(tags$td(strong("Type:"),      style = "padding-right: 16px;"), tags$td("Longitudinal one-mode network")),
                tags$tr(tags$td(strong("Directed:")), tags$td("Yes")),
                tags$tr(tags$td(strong("Weighted:")), tags$td("No (binary)")),
                tags$tr(tags$td(strong("Waves:")),    tags$td("15 weekly observations (frat0 \u2013 frat15, excluding frat9)")),
                tags$tr(tags$td(strong("Domain:")),   tags$td("Social Psychology / Small Group Dynamics / Longitudinal SNA"))
              )
            ),
            tags$table(
              class = "table table-condensed table-hover",
              style = "font-size: 13px;",
              tags$thead(tags$tr(
                tags$th("R Object"), tags$th("Value", style = "text-align: center;"), tags$th("Description")
              )),
              tags$tbody(
                tags$tr(tags$td(tags$code("frat_n")),     tags$td("list of 15",    style = "text-align: center;"), tags$td("Directed network objects, one per wave")),
                tags$tr(tags$td("Nodes per wave"),        tags$td("17",            style = "text-align: center;"), tags$td("Fraternity members (labeled X1\u2013X17)")),
                tags$tr(tags$td("Edges per wave (avg.)"), tags$td("\u224851 edges", style = "text-align: center;"), tags$td("Directed friendship nominations"))
              )
            ),
            hr(),
            h5("Attributes"),
            tags$ul(
              tags$li(strong("Node: "), "name (X1\u2013X17, anonymized member identifier)"),
              tags$li(strong("Edge: "), "None (binary)")
            ),
            hr(),
            h5("References"),
            tags$ul(
              tags$li("Newcomb, T. M. (1961). The Acquaintance Process. Holt, Rinehart & Winston."),
              tags$li("Nordlie, P. G. (1958). A longitudinal study of interpersonal attraction in a natural group setting. Unpublished doctoral dissertation, University of Michigan."),
              tags$li("Wasserman, S., & Faust, K. (1994). Social Network Analysis: Methods and Applications. Cambridge University Press.")
            )
          )
        )
      ),
      tab_stats   # default fallback
    )
  })

  # ── Helpers ───────────────────────────────────────────────────────────────

  # Collect current display settings as a named list
  plot_params <- reactive({
    list(
      displaylabels = isTRUE(input$show_labels),
      usearrows     = isTRUE(input$show_arrows),
      vertex.col    = input$node_color %||% "#CC0000",
      edge.col      = input$edge_color %||% "#555555",
      vertex.cex    = input$node_size  %||% 1.2,
      label.cex     = input$label_size %||% 0.7
    )
  })

  # Extract network at a 1-based time point (converts to 0-based for networkDynamic)
  net_at <- function(t_one_based) {
    network.extract(frat_tnet, at = t_one_based - 1)
  }

  # ── Tab 1: Statistics ──────────────────────────────────────────────────────

  output$stat_density <- renderValueBox({
    t   <- input$time_point %||% 1
    val <- round(net_stats$density[t], 3)
    valueBox(val, paste("Density  ·  T", t), icon = tags$i(class = "fas fa-circle-nodes", "aria-hidden" = "true"), color = "red")
  })

  output$stat_transitivity <- renderValueBox({
    t   <- input$time_point %||% 1
    val <- round(net_stats$transitivity[t], 3)
    valueBox(val, paste("Transitivity  ·  T", t), icon = tags$i(class = "fas fa-triangle-exclamation", "aria-hidden" = "true"), color = "black")
  })

  output$stat_reciprocity <- renderValueBox({
    t   <- input$time_point %||% 1
    val <- round(net_stats$reciprocity[t], 3)
    valueBox(val, paste("Reciprocity  ·  T", t), icon = tags$i(class = "fas fa-arrows-left-right", "aria-hidden" = "true"), color = "red")
  })

  output$stat_edges <- renderValueBox({
    t   <- input$time_point %||% 1
    val <- net_stats$e_count[t]
    valueBox(val, paste("Active Edges  ·  T", t), icon = tags$i(class = "fas fa-diagram-project", "aria-hidden" = "true"), color = "black")
  })

  output$stats_lineplot <- renderPlot({
    req(input$stat_metric)

    metric_labels <- c(
      density      = "Density",
      transitivity = "Transitivity",
      reciprocity  = "Reciprocity",
      e_count      = "Edge Count",
      v_count      = "Node Count"
    )

    metric <- input$stat_metric
    df     <- net_stats
    df$y   <- df[[metric]]

    # Highlight current time point
    current_t  <- input$time_point %||% 1
    current_pt <- df[df$time_point == current_t, ]

    ggplot(df, aes(x = time_point, y = y)) +
      geom_line(color = "#CC0000", linewidth = 1.1) +
      geom_point(color = "#CC0000", size = 3) +
      geom_point(
        data   = current_pt,
        aes(x = time_point, y = y),
        shape  = 21, size = 5,
        fill   = "#CC0000", color = "#000000", stroke = 2
      ) +
      scale_x_continuous(breaks = seq_len(N_TIME_POINTS)) +
      labs(
        x        = "Time Point (Week)",
        y        = metric_labels[metric],
        title    = paste(metric_labels[metric], "Over Time"),
        subtitle = paste("Current selection: Time Point", current_t, "(outlined)")
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title       = element_text(color = "#CC0000", face = "bold"),
        plot.subtitle    = element_text(color = "#555555", size = 13),
        panel.grid.minor = element_blank(),
        axis.title       = element_text(size = 14),
        axis.text        = element_text(size = 13)
      )
  })

    # ── Tab 2: Snapshots ──────────────────────────────────────────────────────

  # Reactive: extract the right network slice based on sidebar mode
  snapshot_net <- reactive({
    if (isTRUE(input$use_window)) {
      req(input$time_window)
      network.extract(frat_tnet,
        onset    = input$time_window[1],
        terminus = input$time_window[2]
      )
    } else {
      req(input$time_point)
      net_at(input$time_point)
    }
  })

  output$snapshot_title <- renderUI({
    if (isTRUE(input$use_window)) {
      req(input$time_window)
      tags$span(paste0(
        "Aggregated Network — Window T",
        input$time_window[1], " to T", input$time_window[2]
      ))
    } else {
      tags$span(paste("Network at Time Point", input$time_point %||% 1))
    }
  })

  output$snapshot_single <- renderPlot({
    p <- plot_params()
    g <- snapshot_net()

    main_label <- if (isTRUE(input$use_window)) {
      paste0("Window T", input$time_window[1], " → T", input$time_window[2],
             "  (all edges active in window)")
    } else {
      paste("Friendship Network — Time Point", input$time_point)
    }

    par(mar = c(0, 0, 2, 0))
    plot(
      g,
      main          = main_label,
      displaylabels = p$displaylabels,
      usearrows     = p$usearrows,
      vertex.col    = p$vertex.col,
      edge.col      = p$edge.col,
      vertex.cex    = p$vertex.cex,
      label.cex     = p$label.cex
    )
  })

  # ── Tab 3: Multi-Time Views ────────────────────────────────────────────────

  output$plot_filmstrip <- renderPlot({
    filmstrip(
      frat_tnet,
      displaylabels = isTRUE(input$show_labels),
      label.cex     = (input$label_size * 2) %||% 2
    )
  }, height = 1560)

  output$plot_prism <- renderPlot({
    req(input$prism_times)
    times <- as.integer(input$prism_times)
    if (length(times) < 2) times <- c(0, 7, 14)

    par(mar = c(1, 1, 1, 1))
    timePrism(
      frat_tnet,
      at            = times,
      displaylabels = isTRUE(input$show_labels),
      planes        = TRUE,
      label.cex     = (input$label_size * 2) %||% 2
    )
  }, height = 800)

  output$timeline_description <- renderUI({
    if (isTRUE(input$timeline_type == "activity")) {
      "Activity Timeline: shows when each node and edge is active. Long segments = stable relationships."
    } else {
      "Proximity Timeline: nodes are positioned by social closeness. Overlapping lines = similar network position."
    }
  })

  output$plot_timeline <- renderPlot({
    if (isTRUE(input$timeline_type == "activity")) {
      par(mar = c(4, 6, 2, 2))
      timeline(frat_tnet)
    } else {
      par(mar = c(4, 4, 4, 4))
      proximity.timeline(
        frat_tnet,
        default.dist = 6,
        mode         = "sammon",
        labels.at    = MAX_TIME,
        vertex.cex   = 4
      )
    }
  }, height = 480)

    # ── Tab 4: Animation ──────────────────────────────────────────────────────

  # render.d3movie requires the full networkDynamic object with pre-computed
  # animation coordinates (set by compute.animation in global.R).
  # network.extract() strips those coordinates, so the sidebar time slider
  # does not apply here. The widget has its own built-in play/pause/scrub controls.

  output$d3_animation <- renderUI({
    render.d3movie(
      frat_tnet,
      usearrows     = isTRUE(input$anim_arrows),
      displaylabels = isTRUE(input$anim_labels),
      bg            = input$anim_bg         %||% "black",
      vertex.col    = input$anim_node_color %||% "firebrick1",
      edge.col      = input$anim_edge_color %||% "ivory",
      vertex.border = input$anim_bg         %||% "black",
      output.mode   = "htmlWidget"
    )
  })

  output$download_animation <- downloadHandler(
    filename = "frat_animation.html",
    content  = function(file) {
      render.d3movie(
        frat_tnet,
        filename      = file,
        usearrows     = isTRUE(input$anim_arrows),
        displaylabels = isTRUE(input$anim_labels),
        bg            = input$anim_bg         %||% "black",
        vertex.col    = input$anim_node_color %||% "firebrick1",
        edge.col      = input$anim_edge_color %||% "ivory",
        vertex.border = input$anim_bg         %||% "black",
        output.mode   = "HTML",
        launchBrowser = FALSE
      )
    }
  )
}