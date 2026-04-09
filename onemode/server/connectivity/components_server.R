components <- function(input, output, session, rv, g, components_result, vis_base) {
  output$component_stats <- renderUI({
    g <- g()
    comp <- components_result()

    n_components <- comp$no
    sizes <- comp$csize
    main_size <- max(sizes)
    isolates <- sum(igraph::degree(g) == 0)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Components: "), n_components),
        tags$li(strong("Main Component Size: "), main_size, " nodes"),
        tags$li(strong("Isolates: "), isolates, " nodes"),
        tags$li(strong("Network Connectivity: "), ifelse(n_components == 1, "Fully Connected", "Fragmented"))
      )
    )
  })
  
  output$component_size_dist <- renderPlotly({
    req(rv$igraph)
    
    g <- g()
    comp <- components_result()
    sizes <- sort(comp$csize, decreasing = TRUE)
    
    plot_ly(x = 1:length(sizes), y = sizes, type = "bar") %>%
      layout(
        title = "Component Size Distribution",
        xaxis = list(title = "Component ID"),
        yaxis = list(title = "Size (Number of Nodes)")
      )
  })
  
  output$components_plot <- renderVisNetwork({
    comp <- components_result()

    colors <- get_ncstate_colors(comp$no)

    vis_data <- igraph_to_visNetwork(g(), input$layout)
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$color.background <- colors[comp$membership]
    vis_data$nodes$group            <- as.character(comp$membership)

    edge_result <- apply_edge_styling(vis_data, g(),
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    weight_result <- apply_weight_style(vis_data, g(), input$weight_style)
    vis_data <- weight_result$vis_data

    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visEdges(smooth = edge_result$smooth) %>%
      visPhysics(solver = "forceAtlas2Based",
                forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                    zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  output$components_ggraph <- renderPlot({
    comp      <- components_result()
    palette   <- get_ncstate_colors(comp$no)
    fill_cols <- palette[comp$membership]
    build_ggraph_plot(g(), input, node_fill_override = fill_cols)
  }, res = 110)

  output$component_membership_table <- renderDT({
    req(rv$igraph)
    
    g <- g()
    comp <- components_result()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    df <- data.frame(
      Node = node_names,
      Component = comp$membership,
      Component_Size = comp$csize[comp$membership]
    )
    
    df <- df[order(df$Component, df$Node), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
}