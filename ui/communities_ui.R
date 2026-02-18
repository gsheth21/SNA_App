communities_ui <- tagList(
  # tabName = "communities",
  
  # Work in Progress Box
  fluidRow(
    create_wip_box(
      chapter_name = "Communities",
      topics = c(
        "Community detection algorithms (Louvain, Fast Greedy, etc.)",
        "Modularity scores",
        "Clique analysis",
        "K-core decomposition",
        "Overlapping communities",
        "Hierarchical clustering"
      ),
      coming_soon_text = "🚧 This chapter is under development!"
    )
  )
)