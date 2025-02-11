#' Adds annotation to Variants
#'
#' Given a gtf, annotates each variant (usually SNPS, but can be any one base genomic feature) based on what it overlaps.
#'
#' @param snps GRanges for each variant.
#' @param gtf The GTF from which the annotation is to be loaded.
#' @param autoChr Try and automatically strip/add 'chr' to chromosome names to match gtf and snps.
#' @return A GRanges
#' @importFrom stats aggregate
#' @importFrom GenomicFeatures tidyExons tidyIntrons makeTxDbFromGFF genes
#' @importFrom S4Vectors queryHits
#' @importFrom rtracklayer import
#' @importFrom utils relist
#' @export
annotateSNPs = function(snps,gtf,autoChr=TRUE){
  #First make a txdb object
  txdb = makeTxDbFromGFF(gtf)
  #Get genes
  gns = genes(txdb)
  #Get introns 
  exons = tidyExons(txdb)
  introns = tidyIntrons(txdb)
  regions = list(Genic=gns,Intronic=introns,Exonic=exons)
  #Fix chr if needed
  if(autoChr & any(grepl('^chr',seqlevels(snps)))!=any(grepl('^chr',seqlevels(gns)))){
    if(any(grepl('^chr',seqlevels(snps)))){
      regions = lapply(regions,function(e) renameSeqlevels(e,paste0('chr',seqlevels(e)))) 
    }else{
      regions = lapply(regions,function(e) renameSeqlevels(e,gsub('^chr','',seqlevels(e)))) 
    }
  }
  #Now annotate things
  snps$regionType = 'InterGenic'
  snps$geneID = as.character(NA) 
  #Set things in order
  for(regionName in names(regions)){
    tgts = regions[[regionName]]
    #Find overlaps
    o = findOverlaps(snps,tgts,ignore.strand=TRUE)
    #Update region type
    snps$regionType[queryHits(o)] = regionName
    table(snps$regionType)/length(snps)*100
    #Merge gene IDs
    oo = data.frame(o)
    oo$geneID = tgts$gene_id[oo$subjectHits]
    oo = aggregate(geneID ~ queryHits,data=oo,FUN=c)
    oo$geneID = lapply(oo$geneID,unique)
    snps$geneID[oo$queryHits] = oo$geneID
  }
  #Load the full thing to get gene Names
  raw = import(gtf)
  #Get gene names
  dd = data.frame(geneID = raw$gene_id,geneName = raw$gene_name)
  dd = unique(dd)
  dd$geneName = make.unique(dd$geneName)
  snps$geneName = relist(dd$geneName[match(unlist(snps$geneID),dd$geneID)],snps$geneID)
  #Save all the details
  snps@metadata$txdb = txdb
  snps@metadata$gtf = raw
  snps@metadata$geneMap = dd
  return(snps)
}

