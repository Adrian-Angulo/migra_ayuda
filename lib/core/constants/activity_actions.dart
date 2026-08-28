class ActivityActions {
  static String login() => "Iniciar de Sesión";
  static String loginGoogle() => "Iniciar Sesión con Google";
  static String logout() => "Cerrar sesión";
  static String entityViewed() => "Ver entidad";
  static String routeRequested() => "Como llegar";
  static String navigationMaps() => "Navegar";
  static String addComment() => "Agregar comentario";
  static String updateComment() => "Agregar comentario";
  static String deleteComment() => "Eliminar comentario";
  static String filter() => "Filtrar";
  static String changeLanguaje() => "Cambiar Idioma";
  static List<String> types() => [
    login(),
    loginGoogle(),
    logout(),
    entityViewed(),
    routeRequested(),
    navigationMaps(),
    addComment(),
    updateComment(),
    deleteComment(),
    filter(),
    changeLanguaje(),
  ];
}