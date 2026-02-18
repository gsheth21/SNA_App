load_network_data <- function(dataset_name) {
  # Load .rda files from intronets package or local directory
  data_path <- file.path("data", paste0(dataset_name, ".rda"))
  
  if (file.exists(data_path)) {
    load(data_path)
    network_obj <- get(dataset_name)
  } else {
    # Try loading from package
    tryCatch({
      data(list = dataset_name, package = "intronets", envir = environment())
      network_obj <- get(dataset_name)
    }, error = function(e) {
      # Create sample network if data not found
      network_obj <- generate_sample_network()
    })
  }
  
  return(network_obj)
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

# Get dataset description/metadata
get_dataset_description <- function(dataset_name) {
  descriptions <- list(
    "ifm" = "Hi-Tech Managers Network: Advice network among managers in a high-tech company with attributes including department, tenure, and level.",
    
    "drugnet" = "Hartford Drug Users Network: Network of drug users in Hartford, CT. Contains demographic information including ethnicity, gender, and drug use patterns. Used for assortativity analysis.",
    
    "github" = "GitHub Collaboration Network: Online interactions among software developers at a top tech company. Each tie represents shared contributions to GitHub repositories. Contains 174 nodes with collaboration patterns.",
    
    "karate" = "Zachary's Karate Club: Classic social network of friendships in a university karate club. Often used to demonstrate community detection algorithms.",
    
    "flomarriage" = "Florentine Families Marriage Network: Marriage ties among Renaissance Florentine families. Historical network used to study elite power structures.",
    
    "flobusiness" = "Florentine Families Business Network: Business relationships among Renaissance Florentine families.",
    
    "sampson" = "Sampson's Monks Network: Social relationships among monks in a monastery. Multiple relation types including liking, esteem, and influence.",
    
    "faux.mesa.high" = "Simulated High School Friendship Network: Synthetic network based on real adolescent friendship patterns with grade and race attributes."
  )
  
  return(descriptions[[dataset_name]] %||% 
         "Network dataset for social network analysis. Contains nodes (actors) and edges (relationships) with various attributes.")
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