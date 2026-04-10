# Source all chapter servers
source(here::here("ego", "server", "setup_server.R"))
source(here::here("ego", "server", "analysis_server.R"))

source(here::here("shared", "helpers", "ui_helpers.R"))
source(here::here("shared", "helpers", "network_helpers.R"))
source(here::here("shared", "helpers", "plot_helpers.R"))
source(here::here("shared", "helpers", "ggraph_helpers.R"))

server <- function(input, output, session) {
  
  # Initialize reactive values
  rv <- reactiveValues(
    current_tab = "setup",
    ego_id = 10,
    igraph_alters = NULL,
    igraph_ego = NULL
  )

  # ── Tab Navigation ──────────────────────────────────────────────────────────
  
  # Listen for tab changes from header
  observe({
    if (!is.null(session$clientData$url_hash)) {
      hash <- session$clientData$url_hash
      if (nzchar(hash)) {
        rv$current_tab <- hash
      }
    }
  })

  # Update tab via JavaScript in header clicks
  observe({
    tab_from_js <- input$current_tab
    if (!is.null(tab_from_js) && nzchar(tab_from_js)) {
      rv$current_tab <- tab_from_js
    }
  })

  # ── Render Dynamic Ego Selector ─────────────────────────────────────────────
  
  output$ego_selector_ui <- renderUI({
    # Build choices from loaded ego networks
    ego_choices <- setNames(
      as.character(all_ego_ids),
      paste0("Ego ", all_ego_ids, " (N=", 
             alter_summary$n_alters[match(all_ego_ids, alter_summary$ego_id)], 
             " alters)")
    )
    
    selectInput(
      "ego_id",
      "Select Ego (ID):",
      choices = ego_choices,
      selected = all_ego_ids[1]  # Select first ego by default
    )
  })

  # Update ego networks when selection changes
  observe({
    ego_id <- as.numeric(input$ego_id)
    rv$ego_id <- ego_id
    
    # Load networks for this ego
    rv$igraph_alters <- get_alter_network(ego_id)
    rv$igraph_ego <- get_alter_ego_network(ego_id)
  }) %>% bindEvent(input$ego_id, ignoreNULL = TRUE, ignoreInit = FALSE)

  # ── Ego Profile Summary (Sidebar) ────────────────────────────────────────────
  
  output$ego_profile_summary <- renderUI({
    req(rv$ego_id)
    profile <- get_ego_profile(rv$ego_id)
    
    if (nrow(profile) == 0) return(NULL)
    
    sex_label <- if (profile$SEX[1] == 1) "Male" else "Female"
    race_label <- if (profile$NWHITE[1] == 1) "Non-White" else "White"
    
    tagList(
      tags$div(
        style = "padding-left: 20px; border-radius: 4px; margin-bottom: 10px;",
        tags$ul(
          style = "margin: 0; padding-left: 15px; font-size: 13px;",
          tags$li(HTML(paste0("<strong>Age:</strong> ", profile$AGE[1]))),
          tags$li(HTML(paste0("<strong>Gender:</strong> ", sex_label))),
          tags$li(HTML(paste0("<strong>Race:</strong> ", race_label))),
          tags$li(HTML(paste0("<strong>Education:</strong> ", profile$EDUC[1])))
        )
      )
    )
  })

  # ── Alter Attribute Controls (Sidebar) ───────────────────────────────────────
  
  output$alter_attribute_controls <- renderUI({
    req(rv$igraph_alters)
    g <- rv$igraph_alters
    attrs <- igraph::vertex_attr_names(g)
    attrs <- attrs[!attrs %in% c("name", "na")]

    if (length(attrs) == 0)
      return(p("No alter attributes available", style = "color: #888;"))

    # Color: all attributes
    color_choices <- c("None", attrs)

    # Size: numeric only
    numeric_attrs <- Filter(function(a) is.numeric(igraph::vertex_attr(g, a)), attrs)
    size_choices <- if (length(numeric_attrs) > 0) c("None", numeric_attrs) else c("None")

    tagList(
      selectInput("color_attribute", "Color by Attribute:",
                  choices = color_choices, selected = "None"),
      selectInput("size_attribute", "Size by Attribute:",
                  choices = size_choices, selected = "None")
    )
  })

  # ── Render Tab Content ──────────────────────────────────────────────────────
  
  output$tab_content <- renderUI({
    tab <- rv$current_tab
    
    if (tab == "setup" || is.null(tab)) {
      return(setup_ui)
    } else if (tab == "analysis") {
      return(analysis_ui)
    } else if (tab == "about") {
      return(tagList(
        box(
          title = "About Ego Network Analysis",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          HTML("
            <h4>Egocentric Network Analysis</h4>
            <p>This app allows you to explore egocentric network data from the General Social Survey (GSS).</p>
            <h5>Data Source</h5>
            <p>The GSS is a national probability sample of US adults conducted annually or biannually since the 1970s.
            We use the 2004 dataset with 288 respondents, each reporting up to 5 confidants (alters) with whom they discuss important matters.</p>
            <h5>Structure</h5>
            <ul>
              <li><strong>Egos:</strong> 288 individuals who were surveyed</li>
              <li><strong>Alters:</strong> ~1,400 confidants reported by egos (max 5 per ego)</li>
              <li><strong>Edges:</strong> Relationships among alters with closeness weights</li>
            </ul>
            <h5>Analysis Levels</h5>
            <p>Network analysis operates at three nested levels:</p>
            <ul>
              <li><strong>Ego-Level:</strong> Demographics and attributes of individual egos</li>
              <li><strong>Alter-Level:</strong> Composition of ego's confidant networks</li>
              <li><strong>Edge-Level:</strong> Structure of relationships among alters</li>
            </ul>
          ")
        )
      ))
    } else if (tab == "help") {
      return(tagList(
        box(
          title = "Help & Guide",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          HTML("
            <h4>Getting Started</h4>
            <ol>
              <li><strong>Setup Tab:</strong> First, explore the data structure. Review ego attributes, alter compositions, and edgelists.</li>
              <li><strong>Analysis Tab:</strong> Select an ego from the sidebar and explore their personal network.</li>
            </ol>
            <h4>Sidebar Controls</h4>
            <ul>
              <li><strong>Ego Selection:</strong> Choose which of the 288 egos to analyze</li>
              <li><strong>View Mode:</strong> Toggle between alters-only view or view with ego highlighted</li>
              <li><strong>Layout Algorithm:</strong> Change network visualization algorithm</li>
              <li><strong>Appearance:</strong> Customize node and edge colors, sizes, and styles</li>
            </ul>
            <h4>Key Concepts</h4>
            <p><strong>Weights:</strong> Represent perceived closeness between alters (2=especially close, 1=know each other)</p>
            <p><strong>Density:</strong> Proportion of possible ties among alters (0=no ties, 1=all tied)</p>
            <p><strong>Components:</strong> Number of separate groups within alter network</p>
            <p><strong>Centralization:</strong> Degree to which network is centered on a single alter</p>
          ")
        )
      ))
    }
  })

  # Call chapter server functions with reactive values passed
  setup_server("setup", rv, input, output, session)
  analysis_server("analysis", rv, input, output, session)
}
