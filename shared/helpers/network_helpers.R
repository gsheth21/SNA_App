load_network_data <- function(file_name, object_name) {
  data_path <- here::here("shared", "data", paste0(file_name, ".rda"))
  if (!file.exists(data_path))
    stop(paste("Dataset file not found:", data_path))

  # Load into a private env to avoid polluting global scope
  # (drugnet.rda contains 22 objects; this keeps things clean)
  env <- new.env(parent = emptyenv())
  load(data_path, envir = env)

  if (!exists(object_name, envir = env, inherits = FALSE))
    stop(paste("Object", shQuote(object_name), "not found in", paste0(file_name, ".rda")))

  get(object_name, envir = env, inherits = FALSE)
}

# Generate sample network (fallback)
generate_sample_network <- function() {
  g <- sample_gnp(16, 0.2)
  V(g)$name <- paste0("Node", 1:vcount(g))
  return(g)
}

# Convert network object to igraph if needed
ensure_igraph <- function(net) {
  if (inherits(net, "network")) {
    # Convert network object to igraph
    library(intergraph)
    net <- asIgraph(net)
  }
  
  # Ensure it's an igraph object
  if (!inherits(net, "igraph")) {
    stop("Network object must be either igraph or network class")
  }

  for (attr in c("vertex.names", "na")) {
    if (attr %in% igraph::vertex_attr_names(net))
      net <- igraph::delete_vertex_attr(net, attr)
  }
  for (attr in c("na")) {
    if (attr %in% igraph::edge_attr_names(net))
      net <- igraph::delete_edge_attr(net, attr)
  }
  
  return(net)
}

# Convert network object to network class if needed
ensure_network <- function(net) {
  if (inherits(net, "igraph")) {
    # Convert igraph to network object
    library(intergraph)
    net <- asNetwork(net)
  }
  
  # Ensure it's a network object
  if (!inherits(net, "network")) {
    stop("Network object must be either igraph or network class")
  }
  
  return(net)
}

# Get dataset description/metadata (legacy one-liner — kept for compatibility)
get_dataset_description <- function(dataset_name) {
  descriptions <- list(
    "moreno"   = "Moreno Classroom Sociometry: Classic sociometric friendship network among 33 children, with gender attributes.",
    "ifm"      = "Padgett Florentine Families Marriage Network: Marriage alliances among 16 Renaissance Florentine families circa 1430, with wealth and political attributes.",
    "sampson"  = "Sampson Monastery Study: Friendship ties among 18 monks during a period of internal conflict, with faction membership attributes.",
    "github"   = "GitHub Developer Collaboration Network: Weighted co-contribution network among 174 software developers, 2018–2021.",
    "drugnet"  = "Drug User Social Networks (Hartford, CT): Directed social ties among drug users; two versions — full network and largest connected component.",
    "hi_tech"  = "Krackhardt High-Tech Managers: Multiplex directed networks (friendship, advice, hierarchy) among 21 managers with organizational attributes.",
    "tradenets" = "Countries Trade Networks: Five directed networks (trade commodities + diplomacy) among 24 countries with macroeconomic attributes."
  )
  return(descriptions[[dataset_name]] %||%
           "Network dataset for social network analysis. Contains nodes (actors) and edges (relationships) with various attributes.")
}

# ── Comprehensive Dataset Info UI Renderer ────────────────────────────────────
# Returns a formatted tagList with Background, Network Structure, Attributes,
# and References sections for the given dataset_key.
# Used by: onemode chapter "Dataset Info" sub-tabs and Overview's info box.
render_dataset_info_ui <- function(dataset_key) {
  meta_list <- list(

    moreno = list(
      name       = "Moreno Classroom Sociometry",
      background = paste(
        "Jacob Moreno's classic sociometric data collected from a classroom of 33 children.",
        "Moreno is widely credited as the founder of sociometry — the systematic measurement",
        "of social preferences within groups — and this dataset is among the earliest and most",
        "cited examples of social network data in the history of the field.",
        "Edges represent mutual friendship or positive social nominations between students.",
        "Gender is recorded as a node attribute, enabling analysis of gender-based segregation",
        "in children's peer networks."
      ),
      type       = "One-mode, undirected, binary",
      directed   = "No",
      weighted   = "No",
      domain     = "Developmental Psychology / Sociometry / Classic SNA",
      objects    = list(
        list(obj = "moreno", nodes = 33, edges = 46, desc = "Classroom friendship network")
      ),
      node_attrs = "vertex.names (student identifier), gender (coded 1 or 2)",
      edge_attrs = "None",
      refs       = list(
        "Moreno, J. L. (1934). Who Shall Survive? Foundations of Sociometry. Nervous and Mental Disease Publishing Company."
      )
    ),

    ifm = list(
      name       = "Padgett Florentine Families \u2014 Marriage Network",
      background = paste(
        "The marriage alliance network among 16 prominent Florentine families during the early",
        "15th century (circa 1430). Collected by John Padgett from historical documents, this",
        "is one of the most widely used networks in SNA pedagogy. An edge between two families",
        "indicates at least one recorded marriage alliance. The data capture a pivotal political",
        "struggle for control of Florence, with the Medici family's strategic bridging ties often",
        "cited as a key factor in their political rise."
      ),
      type       = "One-mode, undirected, binary",
      directed   = "No",
      weighted   = "No",
      domain     = "Historical Sociology / Political Sociology / Classic SNA",
      objects    = list(
        list(obj = "ifm", nodes = 16, edges = 20, desc = "Marriage alliance network among Florentine families")
      ),
      node_attrs = "vertex.names (family name), wealth (net wealth in 1427, lira), seats (civic council seats 1282\u20131344), ties (total marriage/business ties in 116-family dataset)",
      edge_attrs = "None",
      refs       = list(
        "Breiger, R., & Pattison, P. (1986). Cumulated social roles. Social Networks, 8, 215\u2013256.",
        "Kent, D. (1978). The Rise of the Medici. Oxford University Press."
      )
    ),

    sampson = list(
      name       = "Sampson Monastery Study",
      background = paste(
        "Samuel Sampson collected data on social interactions among novice monks at a New England",
        "monastery during a period of significant internal conflict. This network reflects positive",
        "friendship ('liking') ties from the final wave of sociometric rankings (SAMPLK3).",
        "A political crisis led to expulsions and voluntary departures, making this dataset",
        "invaluable for studying community structure and faction dynamics.",
        "Node attributes record each monk's faction: Loyal Opposition, Young Turks, Outcasts, or Waverers."
      ),
      type       = "One-mode, undirected, binary",
      directed   = "No",
      weighted   = "No",
      domain     = "Organizational Sociology / Classic SNA / Blockmodeling",
      objects    = list(
        list(obj = "sampson", nodes = 18, edges = 60, desc = "Monk friendship network (SAMPLK3, final wave)")
      ),
      node_attrs = "vertex.names (monk name), group (faction: Loyal Opposition / Young Turks / Outcasts / Waverers), cloisterville (pre-crisis cohort)",
      edge_attrs = "None",
      refs       = list(
        "Breiger, R., Boorman, S., & Arabie, P. (1975). An algorithm for clustering relational data. Journal of Mathematical Psychology, 12, 328\u2013383.",
        "Sampson, S. (1969). Crisis in a cloister. Unpublished doctoral dissertation, Cornell University."
      )
    ),

    github = list(
      name       = "GitHub Developer Collaboration Network",
      background = paste(
        "Collaboration network among software developers at one large (anonymous) technology",
        "company, observed through GitHub activity (January 2018 \u2013 February 2021). Two developers",
        "are linked if they both committed code to at least one common repository. This is a",
        "one-mode projection of an underlying person-by-repository bipartite network.",
        "Edge weights reflect the number of shared repositories.",
        "Not all developers form a single connected component."
      ),
      type       = "One-mode, undirected, weighted",
      directed   = "No",
      weighted   = "Yes (number of shared repositories)",
      domain     = "Computational Social Science / Software Engineering / Organizational Networks",
      objects    = list(
        list(obj = "github", nodes = 174, edges = 890, desc = "Developer co-contribution network")
      ),
      node_attrs = "name (developer identifier, anonymized), component (connected component membership)",
      edge_attrs = "weight (number of shared repositories)",
      refs       = list(
        "Gousios, G., et al. (2014). Lean GHTorrent: GitHub data on demand. MSR 2014, pp. 384\u2013387.",
        "Middleton, J., et al. (2018). Which contributions predict whether developers are accepted into GitHub teams. MSR 2018, pp. 403\u2013413."
      )
    ),

    drugnet = list(
      name       = "Drug User Social Networks (Hartford, CT)",
      background = paste(
        "Social networks among drug users in high-risk sites in Hartford, Connecticut, collected",
        "as part of a study on how social ties facilitate or inhibit risk behaviors associated",
        "with drug use and HIV transmission. Directed edges represent social connections reported",
        "by respondents. Two versions are provided: the full network (drugnet, including isolates)",
        "and the largest connected component (drug_connect).",
        "Node attributes capture ethnicity and gender."
      ),
      type       = "One-mode, directed, binary",
      directed   = "Yes",
      weighted   = "No",
      domain     = "Public Health / Sociology / Risk Behavior Networks",
      objects    = list(
        list(obj = "drugnet",      nodes = 293, edges = 337, desc = "Full network (includes isolates)"),
        list(obj = "drug_connect", nodes = 193, edges = 323, desc = "Largest connected component")
      ),
      node_attrs = "name (respondent identifier), ethnicity (coded 1\u20134), gender (coded numerically)",
      edge_attrs = "None",
      refs       = list(
        "Weeks, M. R., et al. (2002). Social networks of drug users in high-risk sites. AIDS and Behavior, 6(2), 193\u2013206.",
        "Weeks, M. R., et al. (2009). Changing drug users' risk environments. American Journal of Community Psychology, 43(3), 330\u2013344."
      )
    ),

    hi_tech = list(
      name       = "Krackhardt High-Tech Managers",
      background = paste(
        "Three directed relational networks collected from the 21 managers of a high-technology",
        "equipment manufacturer on the west coast of the United States (mid-1980s).",
        "The networks capture advice-seeking (hta), friendship nomination (htf), and formal",
        "reporting (htr) relationships. All share the same node set and attribute table, enabling",
        "direct comparison of formal and informal organizational structure.",
        "This multiplex design makes the dataset ideal for studying alignment between formal hierarchy",
        "and informal networks."
      ),
      type       = "Multiplex one-mode, directed (3 networks, shared node set)",
      directed   = "Yes (all three)",
      weighted   = "No",
      domain     = "Organizational Behavior / Management / Multiplex Networks",
      objects    = list(
        list(obj = "htf", nodes = 21, edges = 102, desc = "Friendship network"),
        list(obj = "hta", nodes = 21, edges = 190, desc = "Advice network"),
        list(obj = "htr", nodes = 21, edges = 20,  desc = "Reports-to (formal hierarchy)")
      ),
      node_attrs = "name (manager name), age (years), tenure (years of service), level (1=CEO, 2=VP, 3=Manager), dept (0\u20134)",
      edge_attrs = "None",
      refs       = list(
        "Krackhardt, D. (1987). Cognitive social structures. Social Networks, 9, 104\u2013134.",
        "Wasserman, S., & Faust, K. (1994). Social Network Analysis: Methods and Applications. Cambridge University Press."
      )
    ),

    tradenets = list(
      name       = "Countries Trade Networks (Wasserman & Faust)",
      background = paste(
        "Five directed networks representing economic and diplomatic relations among 24 countries",
        "(Wasserman & Faust, 1994). Four capture trade commodity flows (manufactured goods, food,",
        "crude materials, minerals/fuels); a fifth captures diplomatic exchange.",
        "Data are drawn from international trade statistics for 1965\u20131980.",
        "A country-level attribute data frame provides macroeconomic context (population growth,",
        "GNP per capita, school enrollment, energy consumption).",
        "The manufactured goods network (mg) includes edge weights; all others are binary."
      ),
      type       = "Multiplex one-mode, directed (5 networks, shared node set)",
      directed   = "Yes (all five)",
      weighted   = "mg only (manufactured goods); others are binary",
      domain     = "International Relations / World Systems Theory / Multiplex Networks",
      objects    = list(
        list(obj = "mg", nodes = 24, edges = 310, desc = "Manufactured Goods \u2014 weighted"),
        list(obj = "f",  nodes = 24, edges = 307, desc = "Foods"),
        list(obj = "c",  nodes = 24, edges = 307, desc = "Crude Materials"),
        list(obj = "m",  nodes = 24, edges = 135, desc = "Minerals & Fuels"),
        list(obj = "d",  nodes = 24, edges = 369, desc = "Diplomatic Exchange")
      ),
      node_attrs = "name (country name)",
      edge_attrs = "weight (trade volume, mg network only)",
      refs       = list(
        "Smith, D., & White, D. (1988). Structure and dynamics of the global economy. Unpublished manuscript.",
        "Wasserman, S., & Faust, K. (1994). Social Network Analysis: Methods and Applications. Cambridge University Press."
      )
    )
  )

  info <- meta_list[[dataset_key]]
  if (is.null(info)) {
    return(p("No dataset information available for the selected dataset."))
  }

  # Build network objects table rows
  obj_rows <- lapply(info$objects, function(o) {
    tags$tr(
      tags$td(tags$code(o$obj)),
      tags$td(o$nodes, style = "text-align: center;"),
      tags$td(o$edges, style = "text-align: center;"),
      tags$td(o$desc)
    )
  })

  tagList(
    h4(info$name, style = "margin-top: 0; color: #CC0000;"),
    hr(),

    h5("Background"),
    p(info$background),
    hr(),

    h5("Network Structure"),
    tags$table(
      class = "table table-condensed",
      style = "font-size: 13px; margin-bottom: 8px; width: auto;",
      tags$tbody(
        tags$tr(tags$td(strong("Type:"),     style = "padding-right: 16px;"), tags$td(info$type)),
        tags$tr(tags$td(strong("Directed:")), tags$td(info$directed)),
        tags$tr(tags$td(strong("Weighted:")), tags$td(info$weighted)),
        tags$tr(tags$td(strong("Domain:")),   tags$td(info$domain))
      )
    ),
    tags$table(
      class = "table table-condensed table-hover",
      style = "font-size: 13px;",
      tags$thead(tags$tr(
        tags$th("R Object"),
        tags$th("Nodes", style = "text-align: center;"),
        tags$th("Edges", style = "text-align: center;"),
        tags$th("Description")
      )),
      tags$tbody(obj_rows)
    ),
    hr(),

    h5("Attributes"),
    tags$ul(
      tags$li(strong("Node: "), info$node_attrs),
      tags$li(strong("Edge: "), info$edge_attrs)
    ),
    hr(),

    h5("References"),
    tags$ul(lapply(info$refs, tags$li))
  )
}

# Get network basic statistics
get_network_stats <- function(g) {
  require(igraph)
  
  stats <- list(
    nodes = vcount(g),
    edges = ecount(g),
    density = round(edge_density(g), 4),
    is_directed = is_directed(g),
    is_weighted = is_weighted(g),
    n_components = components(g)$no,
    is_connected = is_connected(g)
  )
  
  # Only calculate diameter and avg path for connected graphs
  if (stats$is_connected) {
    stats$diameter = diameter(g, directed = stats$is_directed)
    stats$avg_path_length = round(mean_distance(g, directed = stats$is_directed), 3)
  } else {
    stats$diameter = NA
    stats$avg_path_length = NA
  }
  
  # Transitivity (clustering coefficient)
  stats$transitivity = round(transitivity(g, type = "global"), 3)
  
  # Reciprocity (for directed networks)
  if (stats$is_directed) {
    stats$reciprocity = round(reciprocity(g), 3)
  }
  
  return(stats)
}

# Get node attribute names (excluding 'name')
get_node_attributes <- function(g) {
  attrs <- vertex_attr_names(g)
  attrs <- attrs[attrs != "name"]
  return(attrs)
}

# Get edge attribute names
get_edge_attributes <- function(g) {
  attrs <- edge_attr_names(g)
  return(attrs)
}

# Check if attribute is categorical
is_categorical <- function(attr_values) {
  is.character(attr_values) || is.factor(attr_values) || 
    (is.numeric(attr_values) && length(unique(attr_values)) <= 10)
}

# Check if attribute is numeric
is_numeric_continuous <- function(attr_values) {
  is.numeric(attr_values) && length(unique(attr_values)) > 10
}

# Extract edgelist as data frame
get_edgelist_df <- function(g) {
  el <- as_edgelist(g, names = TRUE)
  df <- data.frame(From = el[, 1], To = el[, 2])
  
  # Add edge attributes if they exist
  edge_attrs <- edge_attr_names(g)
  for (attr in edge_attrs) {
    df[[attr]] <- edge_attr(g, attr)
  }
  
  return(df)
}

# Extract adjacency matrix as data frame
get_adjacency_df <- function(g) {
  adj <- as_adjacency_matrix(g, sparse = FALSE)
  df <- as.data.frame(adj)
  
  # Use node names if available
  node_names <- V(g)$name
  if (!is.null(node_names)) {
    rownames(df) <- node_names
    colnames(df) <- node_names
  }
  
  return(df)
}

# Extract node list with attributes
get_node_list_df <- function(g) {
  node_names <- V(g)$name %||% as.character(1:vcount(g))
  df <- data.frame(Node = node_names)
  
  # Add all node attributes
  attrs <- vertex_attr_names(g)
  attrs <- attrs[attrs != "name"]
  
  for (attr in attrs) {
    df[[attr]] <- vertex_attr(g, attr)
  }
  
  return(df)
}

# Null-coalescing operator
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

# Safely get vertex attribute (returns NULL if doesn't exist)
safe_vertex_attr <- function(g, attr_name) {
  tryCatch({
    vertex_attr(g, attr_name)
  }, error = function(e) {
    NULL
  })
}

# Safely get edge attribute (returns NULL if doesn't exist)
safe_edge_attr <- function(g, attr_name) {
  tryCatch({
    edge_attr(g, attr_name)
  }, error = function(e) {
    NULL
  })
}

# Create subgraph from component
extract_component <- function(g, component_id) {
  comp <- components(g)
  nodes_in_comp <- which(comp$membership == component_id)
  induced_subgraph(g, nodes_in_comp)
}

# Get largest component
get_main_component <- function(g) {
  comp <- components(g)
  largest_comp_id <- which.max(comp$csize)
  extract_component(g, largest_comp_id)
}

# Within-block sum of squares for elbow plot
wcss_from_dist <- function(dist_mat, groups) {
  total_wss <- 0
  for (g in unique(groups)) {
    members <- which(groups == g)
    if (length(members) > 1) {
      sub <- dist_mat[members, members]
      total_wss <- total_wss + sum(sub^2) / (2 * length(members))
    }
  }
  total_wss
}

# Build block boundary shapes for permuted matrix plotly heatmap
build_block_lines <- function(boundaries, n) {
  shapes <- list()
  for (b in boundaries) {
    shapes[[length(shapes) + 1]] <- list(
      type = "line", x0 = b - 0.5, x1 = b - 0.5,
      y0 = -0.5, y1 = n - 0.5, xref = "x", yref = "y",
      line = list(color = "steelblue", width = 2)
    )
    shapes[[length(shapes) + 1]] <- list(
      type = "line", x0 = -0.5, x1 = n - 0.5,
      y0 = b - 0.5, y1 = b - 0.5, xref = "x", yref = "y",
      line = list(color = "steelblue", width = 2)
    )
  }
  shapes
}