roles_ui <- tagList(

  tabBox(
    title = "Roles & Equivalence",
    id    = "roles_tabs",
    width = 12,

    # ── Tab 1: Equivalence Demo ─────────────────────────────────────────────
    tabPanel(
      title = "Equivalence Demo",
      value = "roles_equiv_demo",
      icon  = icon("users-cog"),

      fluidRow(
        box(
          title       = "🔄 Role Equivalence Explorer",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Two nodes are considered equivalent if they engage in similar relations with
             other nodes. The strictness of that definition varies by equivalence type."),
          hr(),
          fluidRow(
            column(
              width = 3,
              radioButtons(
                "equiv_type", "Equivalence Type:",
                choices  = c("Structural"  = "structural",
                             "Automorphic" = "automorphic",
                             "Regular"     = "regular"),
                selected = "structural"
              )
            ),
            column(
              width = 3,
              sliderInput("equiv_k", "Number of Groups (k):",
                          min = 2, max = 8, value = 3, step = 1)
            ),
            column(
              width = 3, br(),
              actionButton("compute_equiv", "Compute Groups", class = "btn-primary")
            ),
            column(width = 3, uiOutput("equiv_explanation_ui"))
          )
        )
      ),

      fluidRow(
        box(
          title       = "🕸️ Network Graph",
          width       = 7,
          solidHeader = TRUE,
          status      = "info",
          visNetworkOutput("equiv_demo_plot", height = "420px")
        ),
        box(
          title       = "📋 Role Group Membership",
          width       = 5,
          solidHeader = TRUE,
          status      = "info",
          uiOutput("equiv_group_table")
        )
      )
    ),

    # ── Tab 2: Profile Similarity ───────────────────────────────────────────
    tabPanel(
      title = "Profile Similarity",
      value = "roles_similarity",
      icon  = icon("th"),

      fluidRow(
        box(
          title       = "📐 Structural Similarity Analysis",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Each node's \"profile\" is its row (and column for directed) in the adjacency matrix.
             Nodes with similar profiles → similar roles."),
          hr(),
          fluidRow(
            column(
              width = 3,
              selectInput("sim_method", "Distance Method:",
                choices = c("Euclidean"         = "euclidean",
                            "Correlation-based" = "correlation",
                            "Hamming"           = "hamming"),
                selected = "euclidean")
            ),
            column(
              width = 3,
              selectInput("sim_direction", "Profile Direction:",
                choices = c("Combined (row + column)" = "combined",
                            "Row only (sent ties)"    = "row",
                            "Column only (received)"  = "column"),
                selected = "combined")
            ),
            column(
              width = 3,
              br(),
              checkboxInput("use_weights_sim",
                            "Use edge weights (weighted networks only)",
                            value = FALSE)
            ),
            column(
              width = 3, br(),
              actionButton("calc_similarity", "Compute Similarity", class = "btn-primary")
            )
          )
        )
      ),

      fluidRow(
        box(
          title       = "🔥 Similarity Heatmap",
          width       = 8,
          solidHeader = TRUE,
          status      = "info",
          plotlyOutput("similarity_heatmap", height = "500px")
        ),
        box(
          title       = "📊 Summary Statistics",
          width       = 4,
          solidHeader = TRUE,
          status      = "info",
          uiOutput("similarity_stats_ui")
        )
      )
    ),

    # ── Tab 3: Blockmodeling ────────────────────────────────────────────────
    tabPanel(
      title = "Blockmodeling",
      value = "roles_blockmodel",
      icon  = icon("th-large"),

      fluidRow(
        box(
          title       = "🧩 Blockmodel Analysis",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Blockmodeling partitions nodes into blocks based on role similarity.
             The permuted adjacency matrix groups structurally similar nodes together."),
          hr(),
          fluidRow(
            column(
              width = 3,
              sliderInput("n_blocks", "Number of Blocks (k):",
                          min = 2, max = 8, value = 3, step = 1)
            ),
            column(
              width = 3,
              selectInput("cluster_method", "Linkage Method:",
                choices = c("Complete" = "complete", "Average" = "average",
                            "Ward.D2"  = "ward.D2",  "Single"  = "single"),
                selected = "complete")
            ),
            column(
              width = 3,
              selectInput("block_dist_method", "Distance Metric:",
                choices = c("Euclidean"   = "euclidean",
                            "Correlation" = "correlation",
                            "Hamming"     = "hamming"),
                selected = "euclidean")
            ),
            column(
              width = 3,
              br(),
              checkboxInput("use_weights_block",
                            "Use edge weights (weighted networks only)",
                            value = FALSE)
            )
          ),
          fluidRow(
            column(width = 3, offset = 9, br(),
              actionButton("run_blockmodel", "Run Blockmodel", class = "btn-primary",
                           style = "width: 100%;")
            )
          )
        )
      ),

      fluidRow(
        column(
          width = 6,
          box(title = "📊 Block Membership", width = NULL,
              solidHeader = TRUE, status = "info",
              uiOutput("blockmodel_stats_ui"))
        ),
        column(
          width = 6,
          box(title = "📈 Elbow Plot (choose optimal k)", width = NULL,
              solidHeader = TRUE, status = "info",
              plotlyOutput("elbow_plot", height = "300px"))
        )
      ),

      fluidRow(
        box(
          title       = "🕸️ Network Colored by Block",
          width       = 6,
          solidHeader = TRUE,
          status      = "info",
          visNetworkOutput("blockmodel_plot", height = "420px")
        ),
        box(
          title       = "🔥 Permuted Adjacency Matrix",
          width       = 6,
          solidHeader = TRUE,
          status      = "info",
          plotlyOutput("permuted_matrix_plot", height = "420px")
        )
      ),

      fluidRow(
        box(
          title       = "📋 Block Membership Table",
          width       = 12,
          solidHeader = TRUE,
          status      = "info",
          DTOutput("block_membership_table")
        )
      )
    )
  )
)