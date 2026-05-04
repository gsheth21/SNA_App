viz_ui <- tagList(

  tabBox(
    title = "Step 9 · Visualize the Network",
    id    = "viz_tabs",
    width = 12,

    # ── Static ggraph ─────────────────────────────────────────────────────────
    tabPanel(
      title = "Static (ggraph)",
      value = "viz_ggraph",
      icon  = icon("image"),

      fluidRow(
        box(
          title       = "Word Co-occurrence Network",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Edge width encodes co-occurrence frequency. Node labels are automatically
            repelled to reduce overlap. Change the layout and appearance using the sidebar."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'set.seed(1776)
ggraph(word_graph, layout = "fr") +
  geom_edge_link(aes(width = n), alpha = 0.25) +
  geom_node_point(size = 4) +
  geom_node_text(aes(label = name), repel = TRUE, size = 3.5) +
  scale_edge_width(range = c(0.2, 2)) +
  theme_void()'
          ),
          withSpinner(plotOutput("viz_ggraph_plot", height = "600px"), color = "#CC0000", type = 4)
        )
      )
    ),

    # ── Node-size by degree ────────────────────────────────────────────────────
    tabPanel(
      title = "Sized by Degree",
      value = "viz_degree_sized",
      icon  = icon("circle"),

      fluidRow(
        box(
          title       = "Nodes Sized by Degree",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Node size is proportional to degree — more-connected words appear larger,
            immediately drawing the eye to the hubs of the semantic network."),
          withSpinner(plotOutput("viz_degree_plot", height = "600px"), color = "#CC0000", type = 4)
        )
      )
    ),

    # ── Interactive visNetwork ─────────────────────────────────────────────────
    tabPanel(
      title = "Interactive",
      value = "viz_interactive",
      icon  = icon("hand-pointer"),

      fluidRow(
        box(
          title       = "Interactive Word Network",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Drag nodes, zoom, and hover for details. Node size reflects degree centrality."),
          withSpinner(
            visNetwork::visNetworkOutput("viz_vis_plot", height = "600px"),
            color = "#CC0000", type = 4
          )
        )
      )
    )
  )
)
