## estQTLeffects
## Karl W Broman

#' Calculate QTL effects at each position across the genome
#'
#' Calculates the effects of QTL at each position across the genome
#' using Haley-Knott regression, much like [qtl::effectscan()],
#' but considering multiple phenotypes and not plotting the results
#'
#' @param cross (Optional) Object of class `"cross"`, see
#'   [qtl::read.cross()].
#' @param pheno.col Phenotype columns in cross object.
#' @param what Indicates whether to calculate phenotype averages for
#' each genotype group or to turn these into additive and dominance
#' effects.
#'
#' @return list of matrices; each component corresponds to a position
#' in the genome and is a matrix with phenotypes x effects
#'
#' @details One should first run [qtl::calc.genoprob()];
#' if not, it is run with the default arguments.
#'
#' The estimated effects will be poorly estimated in the case of
#' selective genotyping, as Haley-Knott regression performs poorly in
#' this case.
#'
#' @keywords regression
#' @seealso [iplotMScanone()], [qtl::effectscan()]
#' [cbindQTLeffects()]
#'
#' @examples
#' data(grav)
#' library(qtl)
#' grav <- reduce2grid(calc.genoprob(grav, step=1))
#' out <- estQTLeffects(grav, phe=seq(1, nphe(grav), by=5))
#'
#' @export
estQTLeffects <-
function(cross, pheno.col=1, what=c("means", "effects"))
{
    if(!inherits(cross, "cross"))
        stop("Input cross object should have class \"cross\".")
    cross_type <- crosstype(cross)
    chr_type <- vapply(cross$geno, chrtype, "")

    what <- match.arg(what)
    handled_crosses <- c("bc", "bcsft", "dh", "riself", "risib", "f2", "haploid")
    if(what == "effects" && !(cross_type %in% handled_crosses)) {
        warning("Can't calculate effects for cross type \"", cross_type, "\"; returning means.")
        what <- "means"
    }

    phe <- extractPheno(cross, pheno.col)

    if(!("prob" %in% names(cross$geno[[1]]))) {
        warning("Running calc.genoprob")
        cross <- qtl::calc.genoprob(cross)
    }

    pr <- vector("list", qtl::nchr(cross))
    for(i in 1:qtl::nchr(cross)) {
        pr[[i]] <- cross$geno[[i]]$prob
        if(chr_type[i] == "X")
            # if what="effects", use full X encoding (AA/ABf/ABr/BB/AY/BY)
            # if what="means", use standard (AA/AB/BB/AY/BY)
            pr[[i]] <- qtl::reviseXdata(cross_type, ifelse(what=="effects", "full", "standard"),
                                        qtl::getsex(cross), prob=pr[[i]], cross.attr=attributes(cross))
    }

    eff <- vector("list", sum(vapply(pr, ncol, 1)))
    cur <- 0
    for(i in seq(along=pr)) {
        for(j in 1:ncol(pr[[i]])) {
            cur <- cur + 1
            # lm to estimate phenotype averages in each genotype group
            eff[[cur]] <- t(stats::lm(phe ~ -1 + pr[[i]][,j,])$coef)
            dimnames(eff[[cur]]) <- list(colnames(phe), dimnames(pr[[i]])[[3]])

            if(what == "effects")
                eff[[cur]] <- convert2effects(eff[[cur]], cross_type, chr_type[i])
        }
    }

    eff
}


#' Combine multiple runs of estQTLeffects
#'
#' Combine multiple runs of estQTLeffects by applying cbind to each
#' component
#'
#' @param ... Results of [estQTLeffects()]
#' @param labels Vector of labels to use in the combination.
#'
#' @return list of matrices; each component corresponds to a position
#' in the genome and is a matrix with phenotypes x effects
#'
#' @keywords utilities
#' @seealso [estQTLeffects()]
#'
#' @examples
#' library(qtl)
#' data(fake.f2)
#' fake.f2 <- calc.genoprob(fake.f2)
#' sex <- fake.f2$pheno$sex
#' eff.fem <- estQTLeffects(fake.f2[,sex==0], pheno.col=1)
#' eff.mal <- estQTLeffects(fake.f2[,sex==1], pheno.col=1)
#' eff <- cbindQTLeffects(eff.fem, eff.mal, labels=c("female", "male"))
#'
#' @export
cbindQTLeffects <-
function(..., labels)
{
    dots <- list(...)
    if(missing(labels))
        labels <- as.character(seq(along=dots))
    stopifnot(length(labels) == length(dots))

    if(length(dots) <= 1)
        stop("need to give at least two sets of effects")

    result <- dots[[1]]
    for(i in seq(along=result))
        colnames(result[[i]]) <- paste(labels[1], colnames(result[[i]]), sep=".")

    for(i in 2:length(dots)) {
        if(length(dots[[i]]) != length(result))
            stop("Not all inputs are the sample length: ", paste(vapply(dots, length, 1), sep=" "))
        for(j in seq(along=result)) {
            colnames(dots[[i]][[j]]) <- paste(labels[i], colnames(dots[[i]][[j]]), sep=".")
            result[[j]] <- cbind(result[[j]], dots[[i]][[j]])
        }
    }
    result
}


# convert phenotype averages to QTL effects
convert2effects <-
function(effects, crosstype, chrtype)
{
    if(chrtype == "X") { # damned X chromosome
        if(crosstype=="bc") {
            if(ncol(effects) == 2) { # just one sex
                effects[,1] <- effects[,2] - effects[,1]
                effects <- effects[,1,drop=FALSE]
                colnames(effects) <- "a"
            }
            if(ncol(effects) == 4) { # both sexes
                effects[,1] <- effects[,2] - effects[,1]
                effects[,2] <- effects[,4] - effects[,3]
                effects <- effects[,1:2,drop=FALSE]
                colnames(effects) <- c("a.female", "a.male")
            }
        }
        else if(crosstype=="f2") {
            if(ncol(effects) == 2) { # just one sex
                effects[,1] <- effects[,2] - effects[,1]
                effects <- effects[,1,drop=FALSE]
                colnames(effects) <- "a"
            }
            if(ncol(effects) == 6) { # both sexes, both directions
                effects[,1] <- effects[,2] - effects[,1]
                effects[,2] <- effects[,4] - effects[,3]
                effects[,3] <- effects[,6] - effects[,5]
                effects <- effects[,1:3,drop=FALSE]
                colnames(effects) <- c("a.femaleForw", "a.femaleRev", "a.male")
            }
            if(ncol(effects) == 4) { # both sexes, both directions
                effects[,1] <- effects[,2] - effects[,1]
                effects[,2] <- effects[,4] - effects[,3]
                effects <- effects[,1:2,drop=FALSE]
                if(length(grep("Y$", colnames(effects)[3:4])) > 0) # has males
                    colnames(effects) <- c("a.female", "a.male")
                else
                    colnames(effects) <- c("a.femaleForw", "a.femaleRev")
            }
        }
        else {} # can't handle this case
    } # end of X chr
    else { # autosome
        if(crosstype=="bc" || crosstype=="haploid") {
            effects[,1] <- effects[,2] - effects[,1]
            effects <- effects[,1,drop=FALSE]
            colnames(effects) <- "a"
        }
        else if(crosstype=="f2" || crosstype=="bcsft") {
            a <- (effects[,3] - effects[,1])/2
            d <- (effects[,2] - (effects[,3] + effects[,1])/2)
            effects[,1] <- a
            effects[,2] <- d
            effects <- effects[,1:2,drop=FALSE]
            colnames(effects) <- c("a", "d")
        }
        else if(crosstype=="riself" || crosstype=="risib" || crosstype=="dh") {
            effects[,1] <- (effects[,2] - effects[,1])/2
            effects <- effects[,1,drop=FALSE]
            colnames(effects) <- "a"
        }
        else {} # can't handle other cases
    }

    effects
}

# strip off names; save colnames within the lists
convert_effects <-
function(effects)
{
    names(effects) <- NULL
    for(i in seq(along=effects)) {
        cn <- colnames(effects[[i]])
        nr <- nrow(effects[[i]])

        eff <- effects[[i]]
        dimnames(eff) <- NULL
        eff <- t(eff)

        effects[[i]] <- list(data=eff, x=(1:nr)-1, names=cn)
    }

    effects
}
