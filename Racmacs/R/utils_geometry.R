
#' Function to get the 3D cross product of two vectors
#'
#' @param U Vector 1
#' @param V Vector 2
#'
#' @return Returns the cross product
#'
CrossProduct3D <- function(U, V) {

  c(U[2]*V[3]-U[3]*V[2],
    U[3]*V[1]-U[1]*V[3],
    U[1]*V[2]-U[2]*V[1])

}


#' Function to get surface triangles.
#'
#' This uses the surf.tri function but ensures that all triangles are outward facing.
#'
#' @param coords Coordinates
#' @param mesh_indices Mesh indices
#' @param check_fn Checking function
#' @param ... Additional parameters
#'
surface_tri_norm <- function(coords, mesh_indices, check_fn, ...){

  # Get indices of outer triangles
  face_indices <- geometry::surf.tri(coords, mesh_indices)

  # Work through each face
  for(n in 1:nrow(face_indices)){

    # Get the indices and coords of the triangles
    tri_indices <- face_indices[n,]
    tri_coords  <- coords[tri_indices,]

    # Get the indices and coords of the corresponding tetrahedron
    tetra_n <- which(rowSums(matrix(mesh_indices %in% tri_indices, nrow(mesh_indices), ncol(mesh_indices))) == 3)

    tetra_indices <- mesh_indices[tetra_n,]
    tetra_coords  <- coords[tetra_indices,]

    non_tri_index  <- tetra_indices[!tetra_indices %in% tri_indices]
    non_tri_coords <- coords[non_tri_index,]

    # Use the cross product to get the surface normal
    tri_norm <- CrossProduct3D(U = tri_coords[1,] - tri_coords[2,],
                               V = tri_coords[1,] - tri_coords[3,])

    # Normalise the surface normal
    tri_norm <- tri_norm/sqrt(sum(tri_norm^2))

    # Test a certain distance along the normal with the test function
    tri_mid <- colMeans(tri_coords)
    norm_test_coords <- tri_mid + tri_norm*0.001

    # Check which is further away from the middle of the function
    fn_result <- check_fn(rbind(tri_mid,norm_test_coords), ...)

    if(fn_result[1] < fn_result[2]){
      face_indices[n,] <- rev(face_indices[n,])
    }


    # # Work out if the dot product is positive or negative
    # pv <- non_tri_coords - tri_coords[1,]
    # dp <- tri_norm %*% pv
    #
    #
    # # Reverse triangle coordinates if needed
    # if(non_tri_index %in% face_indices){
    #
    #   # Normalise the surface normal
    #   tri_norm <- tri_norm/sqrt(sum(tri_norm^2))
    #
    #   # Test a certain distance along the normal with the test function
    #   tri_mid <- colMeans(tri_coords)
    #   norm_test_coords <- tri_mid + tri_norm*0.01
    #
    #   # Check which is further away from the middle of the function
    #   fn_result <- check_fn(rbind(tri_mid,norm_test_coords), ...)
    #
    #   if(fn_result[1] < fn_result[2]){
    #     face_indices[n,] <- rev(face_indices[n,])
    #   }
    #
    # } else if(dp > 0){
    #
    #   face_indices[n,] <- rev(face_indices[n,])
    #
    # }

  }

  # Return the face indices
  face_indices

}


