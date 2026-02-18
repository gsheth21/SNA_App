source(here::here("helpers", "ui_helpers.R"))

networks_ui <- tagList(
  # tabName = "networks",
  
  # Work in Progress Box
  fluidRow(
    create_wip_box(
      chapter_name = "Networks",
      topics = c(
        "Network data structures (edgelists, matrices, igraph objects)",
        "Understanding nodes and edges",
        "Node and edge attributes",
        "Network properties (size, density, components)",
        "Data import and export",
        "Network data manipulation"
      ),
      coming_soon_text = "🚧 This chapter is under development!"
    )
  ),
  
  # Preview: Data Table (functional)
  fluidRow(
    box(
      title = "📊 Network Data Preview",
      width = 12,
      solidHeader = TRUE,
      status = "primary",
      radioButtons(
        "data_view",
        "View:",
        choices = c("Edgelist", "Adjacency Matrix", "Nodes"),
        selected = "Edgelist",
        inline = TRUE
      ),
      DTOutput("data_table")
    )
  ),
  
  # Download options
  fluidRow(
    box(
      title = "💾 Download Network Data",
      width = 12,
      solidHeader = TRUE,
      downloadButton("download_csv", "CSV", class = "btn-danger"),
      downloadButton("download_excel", "Excel", class = "btn-danger"),
      downloadButton("download_rdata", "R Data File", class = "btn-danger")
    )
  )
)