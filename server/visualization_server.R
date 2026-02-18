visualization_server <- function(input, output, session, rv) {
  
  output$network_plot <- renderVisNetwork({
    req(rv$igraph)
    g <- rv$igraph
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # NC State color palette
    ncstate_colors <- c("#CC0000", "#000000", "#777777", "#990000", "#FF3333", "#555555")
    
    # Apply visual settings - default size
    vis_data$nodes$size <- input$node_size
    
    # Color by attribute
    if (!is.null(input$color_attribute) && input$color_attribute != "None") {
      attr_values <- vertex_attr(g, input$color_attribute)
      unique_vals <- unique(attr_values)
      color_map <- setNames(ncstate_colors[1:min(length(unique_vals), length(ncstate_colors))], unique_vals)
      vis_data$nodes$color <- list(background = unname(color_map[as.character(attr_values)]))
    } else {
      vis_data$nodes$color <- list(background = "#CC0000", border = "#990000")
    }
    
    # Size by attribute
    if (!is.null(input$size_attribute) && input$size_attribute != "None") {
      attr_values <- vertex_attr(g, input$size_attribute)
      if (is.numeric(attr_values)) {
        scaled_sizes <- scales::rescale(attr_values, to = c(input$node_size * 0.5, input$node_size * 2))
        vis_data$nodes$size <- scaled_sizes
      }
    }
    
    # Shape by attribute
    if (!is.null(input$shape_attribute) && input$shape_attribute != "None") {
      attr_values <- vertex_attr(g, input$shape_attribute)
      unique_vals <- unique(attr_values)
      shape_options <- c("dot", "square", "triangle", "diamond", "star", "triangleDown")
      shape_map <- setNames(shape_options[1:min(length(unique_vals), length(shape_options))], unique_vals)
      vis_data$nodes$shape <- unname(shape_map[as.character(attr_values)])
    } else {
      vis_data$nodes$shape <- "dot"
    }
    
    vis_data$nodes$font <- list(size = input$label_size)
    vis_data$edges$width <- input$edge_width
    vis_data$edges$color <- list(color = "#000000", opacity = input$edge_opacity)
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
      visInteraction(navigationButtons = TRUE, hover = TRUE) %>%
      visEvents(click = "function(nodes) {
        Shiny.setInputValue('selected_node_id', nodes.nodes[0]);
      }")
  })
  
  output$node_details <- renderUI({
    req(input$selected_node_id)
    req(rv$igraph)
    
    node_id <- as.numeric(input$selected_node_id)
    g <- rv$igraph
    
    node_name <- V(g)$name[node_id] %||% as.character(node_id)
    node_degree <- degree(g, node_id)
    neighbors <- neighbors(g, node_id)
    neighbor_names <- V(g)$name[neighbors] %||% as.character(neighbors)
    
    tagList(
      h4(paste("Node:", node_name)),
      tags$ul(
        tags$li(strong("Degree: "), node_degree),
        tags$li(strong("Neighbors: "), paste(neighbor_names, collapse = ", "))
      )
    )
  })
}