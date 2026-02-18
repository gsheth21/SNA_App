roles_ui <- tagList(
  # tabName = "roles",
  
  # Work in Progress Box
  fluidRow(
    create_wip_box(
      chapter_name = "Roles",
      topics = c(
        "Structural equivalence",
        "Automorphic equivalence",
        "Regular equivalence",
        "Block modeling",
        "Role identification",
        "Similarity matrices"
      ),
      coming_soon_text = "🚧 This chapter is under development!"
    )
  )
)