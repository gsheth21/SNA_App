centrality_ui <- tagList(
  # tabName = "centrality",
  
  # Work in Progress Box
  fluidRow(
    create_wip_box(
      chapter_name = "Centrality",
      topics = c(
        "Degree centrality (number of connections)",
        "Closeness centrality (proximity to others)",
        "Betweenness centrality (bridge positions)",
        "Eigenvector centrality (connections to influential nodes)",
        "Centralization scores",
        "Comparing centrality measures"
      ),
      coming_soon_text = "🚧 This chapter is under development!"
    )
  )
)