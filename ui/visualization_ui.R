visualization_ui <- tabItem(
  tabName = "visualization",
  
  # Work in Progress Box
  fluidRow(
    create_wip_box(
      chapter_name = "Visualization",
      topics = c(
        "Interactive network graphs",
        "Multiple layout algorithms",
        "Color/size/shape nodes by attributes",
        "Highlight specific nodes or edges",
        "Export high-quality images",
        "Customize visual appearance"
      ),
      coming_soon_text = "🚧 This chapter is under development!"
    )
  ),
  
  # Preview: Interactive Graph (functional)
  fluidRow(
    box(
      title = "🔍 Interactive Network Graph (Preview)",
      width = 12,
      solidHeader = TRUE,
      status = "primary",
      visNetworkOutput("network_plot", height = "600px")
    )
  ),
  
  # Selected node details
  fluidRow(
    box(
      title = "📝 Node Details (Click a node to view)",
      width = 12,
      solidHeader = TRUE,
      status = "info",
      uiOutput("node_details")
    )
  )
)