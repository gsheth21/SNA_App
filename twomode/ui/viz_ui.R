viz_ui <- tagList(

  tabBox(
    title = "13.3 Visualising Two Mode Networks",
    id    = "viz_tabs",
    width = 12,

    # ── Sub-tab 1: Basic (the pitfall) ─────────────────────────────────────
    tabPanel(
      title = "Basic",
      value = "viz_basic",
      icon  = icon("exclamation-triangle"),

      fluidRow(
        box(
          title       = "The Two-Mode Pitfall",
          width       = 12,
          solidHeader = TRUE,
          status      = "warning",
          p("When you plot a bipartite network without specifying node types, ggraph treats
            all nodes identically — there is no visual distinction between artists and songs.
            This is the common pitfall when starting out with two-mode data."),
          p(tags$small("Fixed plot: stress layout, uniform node size."),
            style = "color: #888; margin-bottom: 10px;"),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px; margin-bottom:12px;",
            'ggraph(a_t_g2, layout = "stress") +
  geom_edge_link(alpha = 0.2) +
  geom_node_point(size = 0.5) +
  theme_void()'
          ),
          withSpinner(plotOutput("viz_basic_plot", height = "500px"), color = "#CC0000", type = 4)
        )
      )
    ),

    # ── Sub-tab 2: Bipartite Layout (fixed) ────────────────────────────────
    tabPanel(
      title = "Bipartite Layout",
      value = "viz_bipartite",
      icon  = icon("columns"),

      fluidRow(
        box(
          title       = "Classic Bipartite Layout — Top/Bottom and Left/Right",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("The bipartite layout separates the two modes onto opposite sides of the plot.
            Adding ", tags$code("aes(color = type)"), " is the minimal step to distinguish them.
            Use ", tags$code("coord_flip()"), " to rotate between vertical and horizontal arrangements."),
          p(tags$small("Fixed plots: colors follow ggraph defaults (type = logical TRUE/FALSE)."),
            style = "color: #888; margin-bottom: 10px;"),
          fluidRow(
            column(6,
              p(tags$strong("Top / Bottom"), style = "text-align:center; font-weight:bold;"),
              tags$pre(
                style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:11px;",
                'ggraph(a_t_g2, layout = "bipartite") +
  geom_edge_link(alpha = 0.1) +
  geom_node_point(aes(color = type), size = 4) +
  theme_void()'
              ),
              withSpinner(plotOutput("viz_bipartite_tb", height = "420px"), color = "#CC0000", type = 4)
            ),
            column(6,
              p(tags$strong("Left / Right (coord_flip)"), style = "text-align:center; font-weight:bold;"),
              tags$pre(
                style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:11px;",
                'ggraph(a_t_g2, layout = "bipartite") +
  geom_edge_link(alpha = 0.1) +
  geom_node_point(aes(color = type), size = 4) +
  coord_flip() +
  theme_void()'
              ),
              withSpinner(plotOutput("viz_bipartite_lr", height = "420px"), color = "#CC0000", type = 4)
            )
          )
        )
      )
    ),

    # ── Sub-tab 3: Force + Color (sidebar-reactive) ─────────────────────────
    tabPanel(
      title = "Force + Color",
      value = "viz_force_color",
      icon  = icon("palette"),

      fluidRow(
        box(
          title       = "Force-Directed Layout with Color by Mode",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Moving away from the bipartite layout lets the network structure emerge naturally.
            Color by mode type distinguishes artists from songs. Use sidebar to change layout,
            colors, node size, and edge opacity."),
          p(tags$small("Sidebar controls: Layout, Artist/Song color, node size, edge opacity."),
            style = "color: #888; margin-bottom: 10px;"),
          withSpinner(plotOutput("viz_force_color_plot", height = "560px"), color = "#CC0000", type = 4)
        )
      )
    ),

    # ── Sub-tab 4: Force + Shape (sidebar-reactive) ─────────────────────────
    tabPanel(
      title = "Force + Shape",
      value = "viz_force_shape",
      icon  = icon("shapes"),

      fluidRow(
        box(
          title       = "Force-Directed Layout with Color + Shape by Mode",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Adding shape alongside color improves accessibility for readers who cannot
            distinguish color. Circles represent artists; squares represent songs."),
          p(tags$small("Sidebar controls: Layout, Artist/Song color, node size, edge opacity."),
            style = "color: #888; margin-bottom: 10px;"),
          withSpinner(plotOutput("viz_force_shape_plot", height = "560px"), color = "#CC0000", type = 4)
        )
      )
    ),

    # ── Sub-tab 5: Styled (sidebar-reactive) ───────────────────────────────
    tabPanel(
      title = "Styled",
      value = "viz_styled",
      icon  = icon("star"),

      fluidRow(
        box(
          title       = "Fully Styled Two-Mode Visualization",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Uses explicit ", tags$code("scale_shape_manual()"), " and ",
            tags$code("scale_color_manual()"), " with matching ", tags$code("name"),
            " arguments to collapse shape and color into a single legend entry per mode.
            Artist and Song labels replace the cryptic TRUE/FALSE default."),
          p(tags$small("Sidebar controls: Layout, Artist/Song color, node size, edge opacity."),
            style = "color: #888; margin-bottom: 10px;"),
          withSpinner(plotOutput("viz_styled_plot", height = "600px"), color = "#CC0000", type = 4)
        )
      )
    )
  )
)
