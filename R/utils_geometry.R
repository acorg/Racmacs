
separate_meshes <- function(mesh) {

  graph <- igraph::graph_from_edgelist(
    rbind(mesh$faces[,1:2], mesh$faces[,2:3]) + 1,
    directed = F
  )
  components <- igraph::components(graph, mode = "strong")
  face_membership <- components$membership[mesh$faces[,1]]
  lapply(unique(components$membership), function(i) {
    list(
      vertices = mesh$vertices,
      faces    = mesh$faces[face_membership == i, , drop = F],
      normals  = mesh$normals
    )
  })

}
