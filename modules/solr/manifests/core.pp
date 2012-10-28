define solr::core($core = $title) {
  include solr

  notify{"Adding solr core: ${core}": }
}