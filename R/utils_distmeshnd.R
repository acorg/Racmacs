
#' A simple mesh generator for non-convex regions in n-D space
#'
#' An unstructured simplex requires a choice of meshpoints (vertex nodes) and a triangulation. This
#' is a simple and short algorithm that improves the quality of a mesh by relocating the meshpoints
#' according to a relaxation scheme of forces in a truss structure. The topology of the truss is
#' reset using Delaunay triangulation. A (sufficiently smooth) user supplied signed distance
#' function (fd) indicates if a given node is inside or outside the region. Points outside the
#' region are projected back to the boundary.
#'
#' @param fdist Vectorized signed distance function, for example mesh.dsphere, accepting an m-by-n matrix, where m is arbitrary, as the first argument.
#' @param fh Vectorized function, for example mesh.hunif, that returns desired edge length as a function of position. Accepts an m-by-n matrix, where n is arbitrary, as its first argument.
#' @param h Initial distance between mesh nodes.
#' @param box 2-by-n matrix that specifies the bounding box. (See distmesh2d for an example.)
#' @param pfix nfix-by-2 matrix with fixed node positions.
#' @param ptol Algorithm stops when all node movements are smaller than ptol
#' @param ttol Controls how far the points can move (relatively) before a retriangulation with delaunayn.
#' @param deltat Size of the time step in Eulers method.
#' @param geps Tolerance in the geometry evaluations.
#' @param deps Stepsize delta x in numerical derivative computation for distance function.
#' @param ... parameters that are passed to fdist and fh
#' @param max_delauney Maximum delauney
#'
#' @noRd
#'
distmeshnd <- function (fdist, fh, h, box, pfix = array(dim = c(0, ncol(box))),
                        ptol = 0.001, ttol = 0.1, deltat = 0.1,
                        geps = 0.1 * h, deps = sqrt(.Machine$double.eps) * h,
                        max_delauney = 10, ...)
{

  dim = ncol(as.matrix(box))
  L0mult = 1 + 0.4/2^(dim - 1)
  rownorm2 = function(x){ drop(sqrt((x^2) %*% rep(1, ncol(x)))) }

  lastdp <- NULL
  temperature <- 1

  # 1. Create initial distribution in bounding box
  if (dim == 1) {
    p = seq(box[1], box[2], by = h)
  }
  else {
    cbox = lapply(1:dim, function(ii) seq(box[1, ii], box[2,
                                                          ii], by = h))
    p = do.call("expand.grid", cbox)
    p = as.matrix(p)
  }

  # 2. Remove points outside the region, apply the rejection method
  message("Performing initial grid search...", appendLF = F)
  p  = p[fdist(p, ...) < geps, ] # Sign function
  r0 = fh(p, ...)                # Bar length function
  p = rbind(pfix, p[stats::runif(nrow(p)) < min(r0)^dim/r0^dim, ])
  N = nrow(p)
  message("done.", appendLF = T)

  if (N <= dim + 1) {
    stop("Not enough starting points inside boundary (is h0 too large?).")
  }

  count = 0
  p0 = 1/.Machine$double.eps

  message("Retriangulating", appendLF = F)
  while (TRUE) {

    # 3. Retriangulation by Delaunay
    if (max(rownorm2(p - p0)) > ttol * h) {

      count = count + 1
      message(".", appendLF = FALSE)
      p0 = p
      t  = geometry::delaunayn(p)
      pmid = matrix(0, nrow(t), dim)
      for (ii in 1:(dim + 1)) {
        pmid = pmid + p[t[, ii], ]/(dim + 1)
      }
      t = t[fdist(pmid, ...) < (-geps), ]

      # 4. Describe each edge by a unique pair of nodes
      localpairs = as.matrix(expand.grid(1:(dim + 1), 1:(dim + 1)))
      localpairs = localpairs[lower.tri(matrix(TRUE, dim + 1, dim + 1)), 2:1]
      pair = array(dim = c(0, 2))
      for (ii in 1:nrow(localpairs)) {
        pair = rbind(pair, t[, localpairs[ii, ]])
      }

      if(nrow(pair) == 0){
        stop("No coords")
      }
      pair = geometry::Unique(pair, TRUE)

      # 5. Graphical output of the current mesh
      # if (dim == 2) {
      #   geometry::trimesh(t, p[, 1:2])
      # }
      # else if (dim == 3) {
      #   if (count%%5 == 0) {
      #     # tetramesh(t, p)
      #     # return(
      #     #   list(
      #     #     indices = t,
      #     #     coords  = p
      #     #   )
      #     # )
      #   }
      # }
      # else {
      #   cat("Retriangulation #", 15, "\n")
      # }

      # Stop if maximum number of triangulations are reached
      if(count == max_delauney){
        message("reached max.")
        return(
          list(
            indices = t,
            coords  = p
          )
        )
      }
    }

    # 6. Move mesh points based on edge lengths L and forces F

    # bars=p(pair(:,1),:)-p(pair(:,2),:);
    bars = p[pair[, 1], ] - p[pair[, 2], ]

    # L=sqrt(sum(bars.^2,2));
    L = rownorm2(bars)

    # L0=feval(fh,(p(pair(:,1),:)+p(pair(:,2),:))/2);
    L0 = fh((p[pair[, 1], ] + p[pair[, 2], ])/2, ...)

    # L0=L0*L0mult*(sum(L.^dim)/sum(L0.^dim))^(1/dim);
    L0 = L0 * L0mult * (sum(L^dim)/sum(L0^dim))^(1/dim)

    # F=max(L0-L,0);
    F = L0 - L
    F[F < 0] = 0

    # Fbar=[bars,-bars].*repmat(F./L,1,2*dim);
    Fbar = cbind(bars, -bars) * matrix(F/L, nrow = nrow(bars), ncol = 2 * dim)

    ii = pair[, t(matrix(1:2, 2, dim))]
    jj = rep(1, nrow(pair)) %o% c(1:dim, 1:dim)
    s = c(Fbar)
    ns = length(s)
    dp = matrix(0, N, dim)
    dp[1:(dim * N)] = rowsum(s, ii[1:ns] + ns * (jj[1:ns] - 1)) # number of items to replace is not a multiple of replacement length
    if (nrow(pfix) > 0)
      dp[1:nrow(pfix), ] = 0
    p = p + deltat * dp


    # 7. Bring outside points back to the boundary
    d = fdist(p, ...)
    ix = d > 0
    gradd = matrix(0, sum(ix), dim)
    for (ii in 1:dim) {
      a = rep(0, dim)
      a[ii] = deps
      d1x = fdist(p[ix, ] + rep(1, sum(ix)) %o% a, ...)
      gradd[, ii] = (d1x - d[ix])/deps
    }
    p[ix, ] = p[ix, ] - (d[ix] %o% rep(1, dim)) * gradd
    maxdp = max(deltat * rownorm2(dp[d < (-geps), ]))

    if(!is.null(lastdp) && maxdp > lastdp){
      temperature <- temperature*0.99
      deltat <- deltat*0.99
    }
    lastdp <- maxdp
    # deltat <- deltat*0.999

    # 8. Termination criterion
    if (maxdp < ptol * h) {
      message("done.")
      return(
        list(
          indices = t,
          coords  = p
        )
      )
    }
  }
}


