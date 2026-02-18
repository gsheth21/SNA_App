igraph_to_visNetwork <- function(g, layout_type = "stress") {
  require(igraph)
  
  # Get layout - using igraph layout functions
  if (layout_type == "stress") {
    # Check if layout_with_stress exists (newer igraph versions)
    if (exists("layout_with_stress", where = "package:igraph", mode = "function")) {
      layout <- layout_with_stress(g)
    } else {
      # Fallback to FR layout for older igraph versions
      layout <- layout_with_fr(g)
    }
  } else if (layout_type == "fr") {
    layout <- layout_with_fr(g)
  } else if (layout_type == "kk") {
    layout <- layout_with_kk(g)
  } else if (layout_type == "circle") {
    layout <- layout_in_circle(g)
  } else if (layout_type == "nicely") {
    layout <- layout_nicely(g)
  } else if (layout_type == "grid") {
    layout <- layout_on_grid(g)
  } else if (layout_type == "sphere") {
    layout <- layout_on_sphere(g)
  } else {
    # Default to FR layout
    layout <- layout_with_fr(g)
  }
  
  # Create nodes dataframe
  node_names <- V(g)$name %||% as.character(1:vcount(g))
  
  nodes <- data.frame(
    id = 1:vcount(g),
    label = node_names,
    x = layout[, 1] * 500,  # Scale for visNetwork
    y = layout[, 2] * 500,
    stringsAsFactors = FALSE
  )

  if (ecount(g) == 0) {
    # Create empty edges dataframe with correct column structure
    edges <- data.frame(
      from = integer(0),
      to = integer(0),
      stringsAsFactors = FALSE
    )
  } else {
    # Create edges dataframe
    edges_list <- as_edgelist(g, names = FALSE)
    edges <- data.frame(
      from = edges_list[, 1],
      to = edges_list[, 2],
      stringsAsFactors = FALSE
    )
    
    # Add arrow for directed graphs
    if (is_directed(g)) {
      edges$arrows <- "to"
    }
  }
  
  return(list(nodes = nodes, edges = edges))
}

# NC State color palette
get_ncstate_colors <- function(n = NULL) {
  ncstate_palette <- c(
    "#CC0000",  # Reynolds Red (primary)
    "#000000",  # Black
    "#990000",  # Dark red
    "#FF3333",  # Light red
    "#555555",  # Dark gray
    "#777777",  # Medium gray
    "#AAAAAA",  # Light gray
    "#FFFFFF"   # White
  )
  
  if (is.null(n)) {
    return(ncstate_palette)
  } else if (n <= length(ncstate_palette)) {
    return(ncstate_palette[1:n])
  } else {
    # If need more colors, interpolate
    return(colorRampPalette(ncstate_palette)(n))
  }
}

# Create color mapping for categorical attributes
create_color_map <- function(attr_values, use_ncstate = TRUE) {
  unique_vals <- unique(attr_values)
  n_colors <- length(unique_vals)
  
  if (use_ncstate) {
    colors <- get_ncstate_colors(n_colors)
  } else {
    colors <- rainbow(n_colors)
  }
  
  color_map <- setNames(colors, unique_vals)
  return(color_map)
}

# Apply colors to nodes by attribute
color_nodes_by_attribute <- function(vis_data, g, attr_name, use_ncstate = TRUE) {
  attr_values <- vertex_attr(g, attr_name)
  color_map <- create_color_map(attr_values, use_ncstate)
  
  vis_data$nodes$color <- list(
    background = unname(color_map[as.character(attr_values)]),
    border = "#000000"
  )
  
  # Add legend info
  vis_data$color_legend <- data.frame(
    Category = names(color_map),
    Color = unname(color_map)
  )
  
  return(vis_data)
}

# Apply sizes to nodes by numeric attribute
size_nodes_by_attribute <- function(vis_data, g, attr_name, min_size = 5, max_size = 30) {
  require(scales)
  
  attr_values <- vertex_attr(g, attr_name)
  
  if (is.numeric(attr_values)) {
    scaled_sizes <- rescale(attr_values, to = c(min_size, max_size))
    vis_data$nodes$size <- scaled_sizes
    
    # Add size legend info
    vis_data$size_legend <- data.frame(
      Value_Range = paste(round(range(attr_values), 2), collapse = " - "),
      Size_Range = paste(round(range(scaled_sizes), 2), collapse = " - ")
    )
  }
  
  return(vis_data)
}

# Apply shapes to nodes by categorical attribute
shape_nodes_by_attribute <- function(vis_data, g, attr_name) {
  attr_values <- vertex_attr(g, attr_name)
  unique_vals <- unique(attr_values)
  
  # Available shapes in visNetwork
  shape_options <- c("dot", "square", "triangle", "diamond", "star", "triangleDown")
  
  if (length(unique_vals) <= length(shape_options)) {
    shape_map <- setNames(shape_options[1:length(unique_vals)], unique_vals)
  } else {
    # Recycle shapes if too many categories
    shape_map <- setNames(rep(shape_options, length.out = length(unique_vals)), unique_vals)
  }
  
  vis_data$nodes$shape <- unname(shape_map[as.character(attr_values)])
  
  # Add shape legend info
  vis_data$shape_legend <- data.frame(
    Category = names(shape_map),
    Shape = unname(shape_map)
  )
  
  return(vis_data)
}

# Create degree distribution plot
plot_degree_distribution <- function(g, log_scale = FALSE) {
  require(ggplot2)
  
  degrees <- igraph::degree(g)
  df <- data.frame(Degree = degrees)
  
  p <- ggplot(df, aes(x = Degree)) +
    geom_histogram(binwidth = 1, fill = "#CC0000", color = "#000000", alpha = 0.7) +
    labs(
      title = "Degree Distribution",
      x = "Degree",
      y = "Frequency"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      axis.title = element_text(size = 12)
    )
  
  if (log_scale) {
    p <- p + 
      scale_x_log10() + 
      scale_y_log10() +
      labs(title = "Degree Distribution (Log-Log Scale)")
  }
  
  return(p)
}

# Create distance heatmap
plot_distance_heatmap <- function(g) {
  require(plotly)
  
  dist_mat <- distances(g)
  node_names <- V(g)$name %||% as.character(1:vcount(g))
  
  plot_ly(
    x = node_names,
    y = node_names,
    z = dist_mat,
    type = "heatmap",
    colorscale = list(
      c(0, "#FFFFFF"),
      c(0.5, "#CC0000"),
      c(1, "#000000")
    ),
    colorbar = list(title = "Distance")
  ) %>%
    layout(
      title = "Geodesic Distance Matrix",
      xaxis = list(title = "", tickangle = 45),
      yaxis = list(title = "")
    )
}

# Create network comparison plots (for simulations)
plot_network_comparison <- function(graphs, titles = NULL, ncol = 2) {
  require(igraph)
  require(gridExtra)
  
  n_graphs <- length(graphs)
  
  if (is.null(titles)) {
    titles <- paste("Network", 1:n_graphs)
  }
  
  par(mfrow = c(ceiling(n_graphs / ncol), ncol), mar = c(1, 1, 2, 1))
  
  for (i in 1:n_graphs) {
    plot(graphs[[i]], 
         vertex.size = 8,
         vertex.color = "#CC0000",
         vertex.frame.color = "#990000",
         vertex.label.cex = 0.7,
         edge.color = "#000000",
         edge.arrow.size = 0.3,
         main = titles[i])
  }
}

# Create centrality comparison plot
plot_centrality_comparison <- function(g, centrality_type = "all") {
  require(ggplot2)
  require(tidyr)
  require(dplyr)
  
  node_names <- V(g)$name %||% as.character(1:vcount(g))
  
  df <- data.frame(Node = node_names)
  
  if (centrality_type %in% c("degree", "all")) {
    df$Degree <- igraph::degree(g, normalized = TRUE)
  }
  
  if (centrality_type %in% c("betweenness", "all")) {
    df$Betweenness <- igraph::betweenness(g, normalized = TRUE)
  }
  
  if (centrality_type %in% c("closeness", "all")) {
    df$Closeness <- igraph::closeness(g, normalized = TRUE)
  }
  
  if (centrality_type %in% c("eigenvector", "all")) {
    df$Eigenvector <- igraph::eigen_centrality(g)$vector
  }
  
  # Reshape to long format
  df_long <- df %>%
    pivot_longer(cols = -Node, names_to = "Centrality", values_to = "Score")
  
  # Plot
  ggplot(df_long, aes(x = Node, y = Score, fill = Centrality)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = get_ncstate_colors(4)) +
    labs(
      title = "Centrality Scores Comparison",
      x = "Node",
      y = "Normalized Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )
}