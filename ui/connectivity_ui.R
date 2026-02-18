connectivity_ui <- tagList(
  # tabName = "connectivity",
  
  # Work in Progress Box
  fluidRow(
    create_wip_box(
      chapter_name = "Connectivity",
      topics = c(
        "Connected components",
        "Shortest paths between nodes",
        "Distance matrices",
        "Diameter and average path length",
        "Bridges and cutpoints",
        "Network reachability"
      ),
      coming_soon_text = "🚧 This chapter is under development!"
    )
  )
)