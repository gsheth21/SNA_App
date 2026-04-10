# ggraph_helpers.R
# Shared helpers for producing ggraph-based network visualizations.
# These mirror the interactive visNetwork plots so students can compare
# the book-style ggraph code with the interactive equivalent.

# Map sidebar node-shape name → R pch filled-shape code
.ggraph_pch <- function(shape_name) {
  switch(shape_name %||% "dot",
    "dot"      = 21,
    "square"   = 22,
    "triangle" = 24,
    "diamond"  = 23,
    "star"     = 11,
    21
  )
}

# Determine per-node fill colors (character vector, length == vcount(g))
.ggraph_fill <- function(g, input, node_fill_override = NULL) {
  if (!is.null(node_fill_override)) return(node_fill_override)

  color_attr <- input$color_attribute %||% "None"
  base_color <- input$node_color %||% "#CC0000"

  if (!is.null(color_attr) && color_attr != "None" &&
      color_attr %in% igraph::vertex_attr_names(g)) {
    attr_vals <- igraph::vertex_attr(g, color_attr)
    lvls      <- unique(attr_vals)
    palette   <- RColorBrewer::brewer.pal(max(length(lvls), 3), "Set1")
    return(palette[as.integer(factor(attr_vals, levels = lvls))])
  }
  rep(base_color, igraph::vcount(g))
}

# Determine per-node sizes (numeric vector, already in ggplot size units)
.ggraph_sizes <- function(g, input, node_size_scores = NULL) {
  base  <- (input$node_size %||% 10) / 3.5   # convert sidebar px → ggplot pt

  if (!is.null(node_size_scores)) {
    scores <- node_size_scores
    scores[is.na(scores) | is.infinite(scores)] <- min(scores[is.finite(scores)], na.rm = TRUE)
    return(scales::rescale(scores, to = c(base * 0.5, base * 3)))
  }

  size_attr <- input$size_attribute %||% "None"
  if (!is.null(size_attr) && size_attr != "None" &&
      size_attr %in% igraph::vertex_attr_names(g)) {
    vals <- as.numeric(igraph::vertex_attr(g, size_attr))
    vals[is.na(vals)] <- mean(vals, na.rm = TRUE)
    return(scales::rescale(vals, to = c(base * 0.5, base * 3)))
  }
  rep(base, igraph::vcount(g))
}

#' Build a ggraph plot that mirrors the sidebar settings.
#'
#' @param g          igraph object
#' @param input      Shiny input list (sidebar controls)
#' @param node_fill_override  character vector length vcount(g); overrides color_attribute
#' @param node_size_scores    numeric vector length vcount(g); overrides size_attribute
#' @param edge_color_override character vector length ecount(g); per-edge colours
#' @param edge_width_override numeric  vector length ecount(g); per-edge widths
#' @param node_label_override character vector length vcount(g); per-node labels
#' @return ggplot object
build_ggraph_plot <- function(
  g,
  input,
  node_fill_override  = NULL,
  node_size_scores    = NULL,
  edge_color_override = NULL,
  edge_width_override = NULL,
  node_label_override = NULL
) {
  require(ggraph)
  require(igraph)
  require(ggplot2)
  require(scales)

  # ── Node visual attributes ────────────────────────────────────────────────
  fill_vals  <- .ggraph_fill(g, input, node_fill_override)
  size_vals  <- .ggraph_sizes(g, input, node_size_scores)
  pch        <- .ggraph_pch(input$node_shape %||% "dot")

  node_names <- node_label_override %||%
                igraph::V(g)$name   %||%
                as.character(seq_len(igraph::vcount(g)))

  igraph::V(g)$gg_fill  <- fill_vals
  igraph::V(g)$gg_size  <- size_vals
  igraph::V(g)$gg_label <- node_names

  # ── Edge visual attributes ────────────────────────────────────────────────
  edge_col   <- input$edge_color   %||% "#555555"
  edge_width <- input$edge_width   %||% 1
  edge_alpha <- input$edge_opacity %||% 0.5
  edge_style <- input$edge_style   %||% "straight"
  hide_arr   <- input$hide_arrows  %||% FALSE
  wt_style   <- input$weight_style %||% "none"
  cv_str     <- input$curve_strength %||% 0.3

  n_edges <- igraph::ecount(g)

  # Edge colour
  if (!is.null(edge_color_override)) {
    e_col_vec <- edge_color_override
  } else if (wt_style == "color" && "weight" %in% igraph::edge_attr_names(g)) {
    wt        <- igraph::E(g)$weight
    e_col_vec <- scales::col_numeric("YlOrRd", range(wt, na.rm = TRUE))(wt)
  } else {
    e_col_vec <- rep(edge_col, n_edges)
  }

  # Edge width
  if (!is.null(edge_width_override)) {
    e_width_vec <- edge_width_override
  } else if (wt_style == "width" && "weight" %in% igraph::edge_attr_names(g)) {
    wt          <- igraph::E(g)$weight
    e_width_vec <- scales::rescale(wt, to = c(0.3, edge_width * 3))
  } else {
    e_width_vec <- rep(edge_width, n_edges)
  }

  # Edge linetype
  if (wt_style == "linetype" && "weight" %in% igraph::edge_attr_names(g)) {
    med      <- median(igraph::E(g)$weight, na.rm = TRUE)
    e_lty    <- ifelse(igraph::E(g)$weight >= med, "solid", "dashed")
  } else {
    e_lty    <- rep("solid", n_edges)
  }

  igraph::E(g)$gg_color <- e_col_vec
  igraph::E(g)$gg_width <- e_width_vec
  igraph::E(g)$gg_lty   <- e_lty

  # ── Layout ───────────────────────────────────────────────────────────────
  layout_str <- input$layout %||% "stress"

  p <- tryCatch(
    ggraph(g, layout = layout_str),
    error = function(e) {
      warning("ggraph layout '", layout_str, "' failed; falling back to 'fr'. ",
              conditionMessage(e))
      ggraph(g, layout = "fr")
    }
  )

  # ── Layers ────────────────────────────────────────────────────────────────
  sel       <- input$layer_selection %||% c("edges", "labels")
  do_edges  <- "edges"  %in% sel
  do_labels <- "labels" %in% sel

  is_directed <- igraph::is_directed(g)
  arr <- if (is_directed && !hide_arr) {
    grid::arrow(length = grid::unit(0.25, "cm"), type = "closed")
  } else {
    NULL
  }
  # end_cap_size <- grid::unit(3, "pt")

  if (do_edges && n_edges > 0) {
    if (edge_style == "curved") {
      p <- p + ggraph::geom_edge_arc(
        ggplot2::aes(colour = gg_color, width = gg_width, linetype = gg_lty),
        alpha    = edge_alpha,
        arrow    = arr,
        end_cap  = ggraph::circle(3, "pt"),
        strength = cv_str
      )
    } else {
      if (is_directed) {
        p <- p + ggraph::geom_edge_link(
          ggplot2::aes(colour = gg_color, width = gg_width, linetype = gg_lty),
          alpha   = edge_alpha,
          arrow   = arr,
          end_cap = ggraph::circle(3, "pt")
        )
      } else {
        p <- p + ggraph::geom_edge_link(
          ggplot2::aes(colour = gg_color, width = gg_width, linetype = gg_lty),
          alpha = edge_alpha
        )
      }
    }
    p <- p +
      ggraph::scale_edge_colour_identity() +
      ggraph::scale_edge_width_identity(guide = "none") +
      ggraph::scale_edge_linetype_identity()
  }

  # Nodes
  p <- p +
    ggraph::geom_node_point(
      ggplot2::aes(fill = gg_fill, size = gg_size),
      shape  = pch,
      colour = "white",
      stroke = 0.3
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_size_identity()

  # Labels
  label_pt <- (input$label_size %||% 12) / 3.5
  if (do_labels) {
    p <- p + ggraph::geom_node_text(
      ggplot2::aes(label = gg_label),
      size          = label_pt,
      colour        = "black",
      vjust         = -1.0,
      check_overlap = TRUE
    )
  }

  p + ggplot2::theme_void() +
    ggplot2::theme(legend.position = "none")
}
