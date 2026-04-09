# igraph_to_visNetwork <- function(g, layout_type = "stress") {
#   require(igraph)
#   require(graphlayouts)
  
#   # Get layout - using igraph layout functions
#   if (layout_type == "fr") {
#     layout <- layout_with_fr(g)
#   } else if (layout_type == "kk") {
#     layout <- layout_with_kk(g)
#   } else if (layout_type == "stress") {
#     layout <- layout_with_stress(g)
#   } else if (layout_type == "circle") {
#     layout <- layout_in_circle(g)
#   } else if (layout_type == "tree") {
#     layout <- layout_as_tree(g)
#   } else if (layout_type == "grid") {
#     layout <- layout_on_grid(g)
#   } else if (layout_type == "bipartite") {
#     layout <- layout_as_bipartite(g)
#   } else if (layout_type == "mds") {
#     layout <- layout_with_mds(g)
#   } else if (layout_type == "randomly") {
#     layout <- layout_randomly(g)
#   } else {
#     # Default to FR layout
#     layout <- layout_with_fr(g)
#   }
  
#   # Create nodes dataframe
#   node_names <- V(g)$name %||% as.character(1:vcount(g))
  
#   nodes <- data.frame(
#     id = 1:vcount(g),
#     label = node_names,
#     x = layout[, 1] * 500,  # Scale for visNetwork
#     y = layout[, 2] * 500,
#     stringsAsFactors = FALSE
#   )

#   if (ecount(g) == 0) {
#     # Create empty edges dataframe with correct column structure
#     edges <- data.frame(
#       from = integer(0),
#       to = integer(0),
#       stringsAsFactors = FALSE
#     )
#   } else {
#     # Create edges dataframe
#     edges_list <- as_edgelist(g, names = FALSE)
#     edges <- data.frame(
#       from = edges_list[, 1],
#       to = edges_list[, 2],
#       stringsAsFactors = FALSE
#     )
    
#     # Add arrow for directed graphs
#     if (is_directed(g)) {
#       edges$arrows <- "to"
#     }
#   }
  
#   return(list(nodes = nodes, edges = edges))
# }

# # NC State color palette
# get_ncstate_colors <- function(n = NULL) {
#   ncstate_palette <- c(
#     "#CC0000",  # Reynolds Red (primary)
#     "#000000",  # Black
#     "#990000",  # Dark red
#     "#FF3333",  # Light red
#     "#555555",  # Dark gray
#     "#777777",  # Medium gray
#     "#AAAAAA",  # Light gray
#     "#FFFFFF"   # White
#   )
  
#   if (is.null(n)) {
#     return(ncstate_palette)
#   } else if (n <= length(ncstate_palette)) {
#     return(ncstate_palette[1:n])
#   } else {
#     # If need more colors, interpolate
#     return(colorRampPalette(ncstate_palette)(n))
#   }
# }

# # Create color mapping for categorical attributes
# create_color_map <- function(attr_values, use_ncstate = TRUE) {
#   unique_vals <- unique(attr_values)
#   n_colors <- length(unique_vals)
  
#   if (use_ncstate) {
#     colors <- get_ncstate_colors(n_colors)
#   } else {
#     colors <- rainbow(n_colors)
#   }
  
#   color_map <- setNames(colors, unique_vals)
#   return(color_map)
# }

# # Apply colors to nodes by attribute
# color_nodes_by_attribute <- function(vis_data, g, attr_name, use_ncstate = TRUE) {
#   attr_values <- vertex_attr(g, attr_name)
#   color_map <- create_color_map(attr_values, use_ncstate)
  
#   vis_data$nodes$color <- list(
#     background = unname(color_map[as.character(attr_values)]),
#     border = "#000000"
#   )
  
#   # Add legend info
#   vis_data$color_legend <- data.frame(
#     Category = names(color_map),
#     Color = unname(color_map)
#   )
  
#   return(vis_data)
# }

# # Apply sizes to nodes by numeric attribute
# size_nodes_by_attribute <- function(vis_data, g, attr_name, min_size = 5, max_size = 30) {
#   require(scales)
  
#   attr_values <- vertex_attr(g, attr_name)
  
#   if (is.numeric(attr_values)) {
#     scaled_sizes <- rescale(attr_values, to = c(min_size, max_size))
#     vis_data$nodes$size <- scaled_sizes
    
#     # Add size legend info
#     vis_data$size_legend <- data.frame(
#       Value_Range = paste(round(range(attr_values), 2), collapse = " - "),
#       Size_Range = paste(round(range(scaled_sizes), 2), collapse = " - ")
#     )
#   }
  
#   return(vis_data)
# }

# # Apply shapes to nodes by categorical attribute
# shape_nodes_by_attribute <- function(vis_data, g, attr_name) {
#   attr_values <- vertex_attr(g, attr_name)
#   unique_vals <- unique(attr_values)
  
#   # Available shapes in visNetwork
#   shape_options <- c("dot", "square", "triangle", "diamond", "star", "triangleDown")
  
#   if (length(unique_vals) <= length(shape_options)) {
#     shape_map <- setNames(shape_options[1:length(unique_vals)], unique_vals)
#   } else {
#     # Recycle shapes if too many categories
#     shape_map <- setNames(rep(shape_options, length.out = length(unique_vals)), unique_vals)
#   }
  
#   vis_data$nodes$shape <- unname(shape_map[as.character(attr_values)])
  
#   # Add shape legend info
#   vis_data$shape_legend <- data.frame(
#     Category = names(shape_map),
#     Shape = unname(shape_map)
#   )
  
#   return(vis_data)
# }

# # Create degree distribution plot
# plot_degree_distribution <- function(g, log_scale = FALSE) {
#   require(ggplot2)
  
#   degrees <- igraph::degree(g)
#   df <- data.frame(Degree = degrees)
  
#   p <- ggplot(df, aes(x = Degree)) +
#     geom_histogram(binwidth = 1, fill = "#CC0000", color = "#000000", alpha = 0.7) +
#     labs(
#       title = "Degree Distribution",
#       x = "Degree",
#       y = "Frequency"
#     ) +
#     theme_minimal() +
#     theme(
#       plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
#       axis.title = element_text(size = 12)
#     )
  
#   if (log_scale) {
#     p <- p + 
#       scale_x_log10() + 
#       scale_y_log10() +
#       labs(title = "Degree Distribution (Log-Log Scale)")
#   }
  
#   return(p)
# }

# # Create distance heatmap
# plot_distance_heatmap <- function(g) {
#   require(plotly)
  
#   dist_mat <- distances(g)
#   node_names <- V(g)$name %||% as.character(1:vcount(g))
  
#   plot_ly(
#     x = node_names,
#     y = node_names,
#     z = dist_mat,
#     type = "heatmap",
#     colorscale = list(
#       c(0, "#FFFFFF"),
#       c(0.5, "#CC0000"),
#       c(1, "#000000")
#     ),
#     colorbar = list(title = "Distance")
#   ) %>%
#     layout(
#       title = "Geodesic Distance Matrix",
#       xaxis = list(title = "", tickangle = 45),
#       yaxis = list(title = "")
#     )
# }

# # Create network comparison plots (for simulations)
# plot_network_comparison <- function(graphs, titles = NULL, ncol = 2) {
#   require(igraph)
#   require(gridExtra)
  
#   n_graphs <- length(graphs)
  
#   if (is.null(titles)) {
#     titles <- paste("Network", 1:n_graphs)
#   }
  
#   par(mfrow = c(ceiling(n_graphs / ncol), ncol), mar = c(1, 1, 2, 1))
  
#   for (i in 1:n_graphs) {
#     plot(graphs[[i]], 
#          vertex.size = 8,
#          vertex.color = "#CC0000",
#          vertex.frame.color = "#990000",
#          vertex.label.cex = 0.7,
#          edge.color = "#000000",
#          edge.arrow.size = 0.3,
#          main = titles[i])
#   }
# }

# # Create centrality comparison plot
# plot_centrality_comparison <- function(g, centrality_type = "all") {
#   require(ggplot2)
#   require(tidyr)
#   require(dplyr)
  
#   node_names <- V(g)$name %||% as.character(1:vcount(g))
  
#   df <- data.frame(Node = node_names)
  
#   if (centrality_type %in% c("degree", "all")) {
#     df$Degree <- igraph::degree(g, normalized = TRUE)
#   }
  
#   if (centrality_type %in% c("betweenness", "all")) {
#     df$Betweenness <- igraph::betweenness(g, normalized = TRUE)
#   }
  
#   if (centrality_type %in% c("closeness", "all")) {
#     df$Closeness <- igraph::closeness(g, normalized = TRUE)
#   }
  
#   if (centrality_type %in% c("eigenvector", "all")) {
#     df$Eigenvector <- igraph::eigen_centrality(g)$vector
#   }
  
#   # Reshape to long format
#   df_long <- df %>%
#     pivot_longer(cols = -Node, names_to = "Centrality", values_to = "Score")
  
#   # Plot
#   ggplot(df_long, aes(x = Node, y = Score, fill = Centrality)) +
#     geom_bar(stat = "identity", position = "dodge") +
#     scale_fill_manual(values = get_ncstate_colors(4)) +
#     labs(
#       title = "Centrality Scores Comparison",
#       x = "Node",
#       y = "Normalized Score"
#     ) +
#     theme_minimal() +
#     theme(
#       plot.title = element_text(hjust = 0.5, face = "bold"),
#       axis.text.x = element_text(angle = 45, hjust = 1),
#       legend.position = "bottom"
#     )
# }

# =============================================================================
# plot_helpers.R
# Supports: directed, undirected, weighted, unweighted graphs.
# Features that don't apply to a graph type are silently skipped.
# =============================================================================

# ── Internal helper ────────────────────────────────────────────────────────────
# Convert a hex color + opacity [0,1] to an "rgba(r,g,b,a)" string.
# Used everywhere instead of list(color=x, opacity=y), which causes row-count errors.
.hex_to_rgba <- function(hex_color, alpha = 1) {
  rgb_vals <- col2rgb(hex_color)
  sprintf("rgba(%d,%d,%d,%.2f)", rgb_vals[1], rgb_vals[2], rgb_vals[3], alpha)
}

# ── 1. Core conversion ────────────────────────────────────────────────────────

igraph_to_visNetwork <- function(g, layout_type = "stress") {
  require(igraph)
  require(graphlayouts)

  coords <- switch(layout_type,
    fr        = layout_with_fr(g),
    kk        = layout_with_kk(g),
    stress    = layout_with_stress(g),
    circle    = layout_in_circle(g),
    tree      = if (isTRUE(igraph::is_tree(g))) {
                  layout_as_tree(g)
                } else {
                  warning("Graph is not a tree; falling back to FR layout.")
                  layout_with_fr(g)
                },
    grid      = layout_on_grid(g),
    bipartite = if (igraph::bipartite_mapping(g)$res) {
                  layout_as_bipartite(g)
                } else {
                  warning("Graph is not bipartite; falling back to FR layout.")
                  layout_with_fr(g)
                },
    mds       = tryCatch(
                  layout_with_mds(g),
                  error = function(e) {
                    warning("MDS layout failed (graph may be disconnected); falling back to FR.")
                    layout_with_fr(g)
                  }
                ),
    randomly  = layout_randomly(g),
    nicely    = layout_nicely(g),
    layout_with_fr(g)   # default
  )

  node_names <- V(g)$name %||% as.character(seq_len(vcount(g)))

  # Build rich HTML tooltips: name + degree + vertex attributes (up to 4)
  deg_vals     <- igraph::degree(g)
  node_tooltip <- paste0("<b>", node_names, "</b><br/>Degree: ", deg_vals)
  v_attrs <- vertex_attr_names(g)
  v_attrs <- v_attrs[!v_attrs %in% c("name", "na")]
  for (a in head(v_attrs, 4)) {
    vals <- vertex_attr(g, a)
    node_tooltip <- paste0(node_tooltip, "<br/><i>", a, ":</i> ", vals)
  }

  nodes <- data.frame(
    id    = seq_len(vcount(g)),
    label = node_names,
    title = node_tooltip,
    x     = coords[, 1] * 500,
    y     = coords[, 2] * 500,
    stringsAsFactors = FALSE
  )

  if (ecount(g) == 0) {
    edges <- data.frame(from = integer(0), to = integer(0), stringsAsFactors = FALSE)
  } else {
    el    <- as_edgelist(g, names = FALSE)
    edges <- data.frame(from = el[, 1], to = el[, 2], stringsAsFactors = FALSE)
    if (is_directed(g)) edges$arrows <- "to"
  }

  list(nodes = nodes, edges = edges)
}

# ── 2. Layer selection (input$layer_selection) ────────────────────────────────
# Nodes always render. Only "edges" and "labels" are togglable.

apply_layer_selection <- function(vis_data, layers = c("edges", "labels")) {
  if (!"labels" %in% layers)
    vis_data$nodes$label <- ""

  if (!"edges" %in% layers)
    vis_data$edges <- data.frame(from = integer(0), to = integer(0), stringsAsFactors = FALSE)

  vis_data
}

# ── 3. Global node styling ────────────────────────────────────────────────────
# Handles: input$node_color, input$node_shape, input$node_size, input$label_size

apply_node_styling <- function(vis_data,
                                node_color = "#CC0000",
                                node_shape = "dot",
                                node_size  = 10,
                                label_size = 12) {
  vis_data$nodes$color.background <- node_color
  vis_data$nodes$color.border     <- "#000000"
  vis_data$nodes$shape             <- node_shape
  vis_data$nodes$size              <- node_size
  vis_data$nodes$font.size         <- label_size
  vis_data
}

# ── 4. Attribute-based node styling ──────────────────────────────────────────

get_ncstate_colors <- function(n = NULL) {
  palette <- c("#CC0000", "#4156A1", "#990000", "#5E72B0",
               "#555555", "#777777", "#AAAAAA", "#FF3333")
  if (is.null(n))           return(palette)
  if (n <= length(palette)) return(palette[seq_len(n)])
  colorRampPalette(palette)(n)
}

create_color_map <- function(attr_values, use_ncstate = TRUE) {
  unique_vals <- unique(attr_values)
  colors      <- if (use_ncstate) get_ncstate_colors(length(unique_vals)) else rainbow(length(unique_vals))
  setNames(colors, unique_vals)
}

color_nodes_by_attribute <- function(vis_data, g, attr_name, use_ncstate = TRUE) {
  attr_values <- vertex_attr(g, attr_name)
  if (is.null(attr_values) || length(attr_values) != vcount(g)) return(vis_data)
  color_map   <- create_color_map(attr_values, use_ncstate)
  vis_data$nodes$color.background <- unname(color_map[as.character(attr_values)])
  vis_data$nodes$color.border     <- "#000000"
  vis_data$color_legend <- data.frame(Category = names(color_map), Color = unname(color_map))
  vis_data
}

size_nodes_by_attribute <- function(vis_data, g, attr_name, min_size = 5, max_size = 30) {
  require(scales)
  attr_values <- vertex_attr(g, attr_name)
  if (is.null(attr_values) || length(attr_values) != vcount(g)) return(vis_data)
  if (is.numeric(attr_values)) {
    scaled <- scales::rescale(attr_values, to = c(min_size, max_size))
    vis_data$nodes$size  <- scaled
    vis_data$size_legend <- data.frame(
      Value_Range = paste(round(range(attr_values), 2), collapse = " - "),
      Size_Range  = paste(round(range(scaled), 2),      collapse = " - ")
    )
  }
  vis_data
}

shape_nodes_by_attribute <- function(vis_data, g, attr_name) {
  attr_values <- vertex_attr(g, attr_name)
  if (is.null(attr_values) || length(attr_values) != vcount(g)) return(vis_data)
  unique_vals <- unique(attr_values)
  shape_opts  <- c("dot", "square", "triangle", "diamond", "star", "triangleDown")
  shape_map   <- setNames(rep(shape_opts, length.out = length(unique_vals)), unique_vals)
  vis_data$nodes$shape  <- unname(shape_map[as.character(attr_values)])
  vis_data$shape_legend <- data.frame(Category = names(shape_map), Shape = unname(shape_map))
  vis_data
}

# ── 5. Edge styling ───────────────────────────────────────────────────────────
# Handles: input$show_arrows, input$edge_width, input$edge_opacity,
#          input$edge_style, input$curve_strength
#
# show_arrows: only has effect on directed graphs (ignored for undirected)
# edge_opacity: now actually applied via rgba string
#
# Returns list(vis_data, smooth) — server must pass result$smooth to visEdges(smooth = ...)

apply_edge_styling <- function(vis_data, g,
                                hide_arrows    = FALSE,
                                edge_color     = "#555555",
                                edge_width     = 1,
                                edge_opacity   = 0.5,
                                edge_style     = "straight",
                                curve_strength = 0.3) {

  smooth <- if (edge_style == "curved") {
    list(enabled = TRUE, type = "curvedCW", roundness = curve_strength)
  } else {
    list(enabled = FALSE)
  }

  if (nrow(vis_data$edges) == 0)
    return(list(vis_data = vis_data, smooth = smooth))

  vis_data$edges$width <- edge_width
  vis_data$edges$color <- .hex_to_rgba(edge_color, edge_opacity)

  # Arrows only apply to directed graphs
  if (is_directed(g)) {
    vis_data$edges$arrows <- if (!hide_arrows) "to" else ""
  }

  list(vis_data = vis_data, smooth = smooth)
}

# ── 6. Edge weight styling (input$weight_style) ───────────────────────────────
# Works for both directed and undirected — no collapsing, directionality preserved.
# Unweighted graphs: weight attribute auto-assigned as 1 (all edges look equal).
# Returns list(vis_data, g_plot)

apply_weight_style <- function(vis_data, g, weight_style = "none") {

  if (weight_style == "none" || ecount(g) == 0)
    return(list(vis_data = vis_data, g_plot = g))

  # Reciprocity: directed only — collapse to undirected, weight = number of arcs
  if (weight_style == "reciprocity") {
    if (!is_directed(g)) return(list(vis_data = vis_data, g_plot = g))

    E(g)$weight <- 1
    g_plot <- as_undirected(g, mode = "collapse",
                             edge.attr.comb = list(weight = "sum", "ignore"))
    el <- as_edgelist(g_plot, names = FALSE)
    weights <- E(g_plot)$weight

    vis_data$edges <- data.frame(from = el[, 1], to = el[, 2], stringsAsFactors = FALSE)
    vis_data$edges$dashes <- weights == 1          # dashed = unidirectional
    vis_data$edges$color  <- ifelse(weights >= 2, "#CC0000", "#AAAAAA")  # red = reciprocated
    vis_data$edges$width  <- ifelse(weights >= 2, 3, 1)
    return(list(vis_data = vis_data, g_plot = g_plot))
  }

  if (!"weight" %in% edge_attr_names(g)) E(g)$weight <- 1
  weights <- E(g)$weight

  if (weight_style == "width") {
    # Proportional width scaling: thin (weak) → thick (strong)
    vis_data$edges$width <- if (length(unique(weights)) == 1) {
      rep(3, length(weights))
    } else {
      scales::rescale(weights, to = c(1, 8))
    }

  } else if (weight_style == "linetype") {
    # Dashed = weak (at or below median), solid = strong
    vis_data$edges$dashes <- weights <= median(weights)
    vis_data$edges$width  <- 2

  } else if (weight_style == "color") {
    # Light gray (weak) → NC State red (strong) gradient
    if (length(unique(weights)) == 1) {
      vis_data$edges$color <- "#CC0000"
    } else {
      t  <- scales::rescale(weights, to = c(0, 1))
      rv <- round(0xAA + t * (0xCC - 0xAA))
      gv <- round(0xAA + t * (0x00 - 0xAA))
      bv <- round(0xAA + t * (0x00 - 0xAA))
      vis_data$edges$color <- sprintf("#%02X%02X%02X", rv, gv, bv)
    }
    vis_data$edges$width <- 1.5
  }

  list(vis_data = vis_data, g_plot = g)
}

# ── 8. Plot utilities ─────────────────────────────────────────────────────────

plot_degree_distribution <- function(g, log_scale = FALSE) {
  require(ggplot2)
  df <- data.frame(Degree = igraph::degree(g))

  p <- ggplot(df, aes(x = Degree)) +
    geom_histogram(binwidth = 1, fill = "#CC0000", color = "#000000", alpha = 0.7) +
    labs(title = "Degree Distribution", x = "Degree", y = "Frequency") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
          axis.title = element_text(size = 12))

  if (log_scale)
    p <- p + scale_x_log10() + scale_y_log10() +
      labs(title = "Degree Distribution (Log-Log Scale)")
  p
}

plot_distance_heatmap <- function(g) {
  require(plotly)
  node_names <- V(g)$name %||% as.character(seq_len(vcount(g)))
  dist_mat   <- distances(g)
  dist_mat[!is.finite(dist_mat)] <- NA  # disconnected pairs show as missing, not Inf

  plot_ly(x = node_names, y = node_names, z = dist_mat, type = "heatmap",
          colorscale = list(c(0, "#FFFFFF"), c(0.5, "#CC0000"), c(1, "#000000")),
          colorbar = list(title = "Distance")) %>%
    layout(title = "Geodesic Distance Matrix",
           xaxis = list(title = "", tickangle = 45),
           yaxis = list(title = ""))
}

plot_network_comparison <- function(graphs, titles = NULL, ncol = 2) {
  require(igraph)
  n <- length(graphs)
  if (is.null(titles)) titles <- paste("Network", seq_len(n))
  par(mfrow = c(ceiling(n / ncol), ncol), mar = c(1, 1, 2, 1))
  for (i in seq_len(n)) {
    plot(graphs[[i]],
         vertex.size        = 8,
         vertex.color       = "#CC0000",
         vertex.frame.color = "#990000",
         vertex.label.cex   = 0.7,
         edge.color         = "#000000",
         edge.arrow.size    = 0.3,
         main               = titles[i])
  }
}

plot_centrality_comparison <- function(g, centrality_type = "all") {
  require(ggplot2); require(tidyr); require(dplyr)

  df <- data.frame(Node = V(g)$name %||% as.character(seq_len(vcount(g))))

  if (centrality_type %in% c("degree",      "all")) df$Degree      <- igraph::degree(g,         normalized = TRUE)
  if (centrality_type %in% c("betweenness", "all")) df$Betweenness <- igraph::betweenness(g,    normalized = TRUE)
  if (centrality_type %in% c("closeness",   "all")) df$Closeness   <- igraph::closeness(g,      normalized = TRUE)
  if (centrality_type %in% c("eigenvector", "all")) df$Eigenvector <- igraph::eigen_centrality(g)$vector

  df %>%
    pivot_longer(-Node, names_to = "Centrality", values_to = "Score") %>%
    ggplot(aes(x = Node, y = Score, fill = Centrality)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = get_ncstate_colors(4)) +
    labs(title = "Centrality Scores Comparison", x = "Node", y = "Normalized Score") +
    theme_minimal() +
    theme(plot.title      = element_text(hjust = 0.5, face = "bold"),
          axis.text.x     = element_text(angle = 45, hjust = 1),
          legend.position = "bottom")
}