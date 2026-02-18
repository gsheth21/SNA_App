# Source all chapter UIs
source(here::here("server", "overview_server.R"))
source(here::here("server", "networks_server.R"))
source(here::here("server", "visualization_server.R"))
source(here::here("server", "connectivity_server.R"))
source(here::here("server", "centrality_server.R"))
source(here::here("server", "communities_server.R"))
source(here::here("server", "assortativity_server.R"))
source(here::here("server", "roles_server.R"))
source(here::here("server", "simulation_server.R"))

source(here::here("helpers", "ui_styles.R"))
source(here::here("helpers", "ui_helpers.R"))
source(here::here("helpers", "network_helpers.R"))
source(here::here("helpers", "plot_helpers.R"))

server <- function(input, output, session) {
  
  # Initialize reactive value for current tab
  current_tab <- reactiveVal("overview")
  
  # Update current_tab when input changes
  observeEvent(input$current_tab, {
    req(input$current_tab)
    cat("Server received tab change to:", input$current_tab, "\n")
    current_tab(input$current_tab)
  }, ignoreNULL = TRUE, ignoreInit = FALSE)
  
  # Debug observer
  observe({
    cat("Current tab is now:", current_tab(), "\n")
  })
  
  # Render tab content dynamically
  output$tab_content <- renderUI({
    tab <- current_tab()
    cat("Rendering UI for tab:", tab, "\n")
    
    # Return content directly from switch
    switch(tab,
      "overview" = tagList(
        tags$div(id = "tab-overview", class = "tab-inner", overview_ui)
      ),
      "networks" = tagList(
        tags$div(id = "tab-networks", class = "tab-inner", networks_ui)
      ),
      "visualization" = tagList(
        tags$div(id = "tab-visualization", class = "tab-inner", visualization_ui)
      ),
      "connectivity" = tagList(
        tags$div(id = "tab-connectivity", class = "tab-inner", connectivity_ui)
      ),
      "centrality" = tagList(
        tags$div(id = "tab-centrality", class = "tab-inner", centrality_ui)
      ),
      "communities" = tagList(
        tags$div(id = "tab-communities", class = "tab-inner", communities_ui)
      ),
      "assortativity" = tagList(
        tags$div(id = "tab-assortativity", class = "tab-inner", assortativity_ui)
      ),
      "roles" = tagList(
        tags$div(id = "tab-roles", class = "tab-inner", roles_ui)
      ),
      "simulation" = tagList(
        tags$div(id = "tab-simulation", class = "tab-inner", simulation_ui)
      ),
      # "overview" = overview_ui,
      # "networks" = networks_ui,
      # "visualization" = visualization_ui,
      # "connectivity" = connectivity_ui,
      # "centrality" = centrality_ui,
      # "communities" = communities_ui,
      # "assortativity" = assortativity_ui,
      # "roles" = roles_ui,
      # "simulation" = simulation_ui,
      "about" = tagList(
        tags$div(
          id = "tab-about", 
          class = "tab-inner",
          fluidRow(
            box(
              title = "ℹ️ About This App",
              width = 12,
              solidHeader = TRUE,
              status = "danger",
              p("This interactive application accompanies the Social Network Analysis textbook."),
              hr(),
              tags$ul(
                tags$li(strong("Course:"), "Social Network Analysis (Sociology & Anthropology, NCSU)"),
                tags$li(strong("Professor:"), "Dr. Steve McDonald"),
                tags$li(strong("Developed by:"), "Dr. Aditi Mallavarapu, Gaurav Sheth"),
                tags$li(strong("Version:"), "1.0.0"),
                tags$li(strong("Last Updated:"), format(Sys.Date(), "%B %d, %Y"))
              )
            )
          )
        )
      ),
      # Default fallback
      {
        cat("WARNING: Unknown tab", tab, "- defaulting to overview\n")
        tagList(
          tags$div(id = "tab-overview", class = "tab-inner", overview_ui)
        )
      }
    )
  })

  rv <- reactiveValues(
    network = NULL,
    igraph = NULL,
    centrality_results = list(),
    community_results = NULL,
    selected_node = NULL,
    simulated_network = NULL,
    erdos_graphs = NULL,
    sw_network = NULL,
    ba_network = NULL,
    walk_path = NULL,
    walk_frequencies = NULL,
    cug_simulations = NULL,
    cug_observed = NULL
  )

  observe({
    req(input$dataset)
    
    # Load network
    net <- load_network_data(input$dataset)
    rv$network <- net
    rv$igraph <- ensure_igraph(net)
    
    # Clear previous results when dataset changes
    rv$centrality_results <- list()
    rv$community_results <- NULL
    rv$selected_node <- NULL
  })

  output$attribute_controls <- renderUI({
    req(rv$igraph)
    
    attrs <- vertex_attr_names(rv$igraph)
    attrs <- attrs[attrs != "name"]
    
    if (length(attrs) > 0) {
      tagList(
        selectInput("color_attribute", "Color by Attribute:", 
                    choices = c("None", attrs), selected = "None"),
        selectInput("size_attribute", "Size by Attribute:", 
                    choices = c("None", attrs), selected = "None"),
        selectInput("shape_attribute", "Shape by Attribute:", 
                    choices = c("None", attrs), selected = "None")
      )
    } else {
      p("No node attributes available", style = "padding-left: 15px;")
    }
  })
  
  # Call chapter-specific server modules
  overview_server(input, output, session, rv)
  networks_server(input, output, session, rv)
  visualization_server(input, output, session, rv)
  connectivity_server(input, output, session, rv)
  centrality_server(input, output, session, rv)
  communities_server(input, output, session, rv)
  assortativity_server(input, output, session, rv)
  roles_server(input, output, session, rv)
  simulation_server(input, output, session, rv)

  output$download_csv <- downloadHandler(
    filename = function() {
      paste0(input$dataset, "_edgelist_", Sys.Date(), ".csv")
    },
    content = function(file) {
      el <- as_edgelist(rv$igraph, names = TRUE)
      df <- data.frame(From = el[, 1], To = el[, 2])
      write.csv(df, file, row.names = FALSE)
    }
  )
}