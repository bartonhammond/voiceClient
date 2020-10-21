import 'package:i18n_extension/i18n_extension.dart';
import 'package:MyFamilyVoice/constants/strings.dart';

extension Localization on String {
  static final _t = Translations('en') +
      {
        'en': Strings.MFV,
        'es': 'Mi Voz Familiar',
      } +
      {
        'en': Strings.ok,
        'es': 'De acuerdo',
      } +
      {
        'en': Strings.cancel,
        'es': 'Cancelar',
      } +
      {
        'en': Strings.areYouSure,
        'es': '¿Estás seguro?',
      } +
      {
        'en': Strings.yes,
        'es': 'Sí',
      } +
      {
        'en': Strings.noResults,
        'es': 'Sin resultados',
      } +
      {
        'en': Strings.upload,
        'es': 'Salvar',
      } +
      {
        'en': Strings.loadMore,
        'es': 'Cargar más',
      } +
      {
        'en': Strings.logout,
        'es': 'Cerrar sesión',
      } +
      {
        'en': Strings.logoutAreYouSure,
        'es': '¿Está seguro de que desea cerrar la sesión?',
      } +
      {
        'en': Strings.logoutFailed,
        'es': 'Error al cerrar la sesión',
      } +
      {
        'en': Strings.zhLocale,
        'es': 'Chino',
      } +
      {
        'en': Strings.usLocale,
        'es': 'Inglés',
      } +
      {
        'en': Strings.deLocale,
        'es': 'Alemán',
      } +
      {
        'en': Strings.hiLocale,
        'es': 'Hindi',
      } +
      {
        'en': Strings.idLocale,
        'es': 'Indonesio',
      } +
      {
        'en': Strings.jaLocale,
        'es': 'Japonés',
      } +
      {
        'en': Strings.koLocale,
        'es': 'Coreano',
      } +
      {
        'en': Strings.ptLocale,
        'es': 'Portugués',
      } +
      {
        'en': Strings.ruLocale,
        'es': 'Ruso',
      } +
      {
        'en': Strings.esLocale,
        'es': 'Español',
      } +
      {
        'en': Strings.signIn,
        'es': 'Inicia sesión',
      } +
      {
        'en': Strings.emailLabel,
        'es': 'Correo electrónico',
      } +
      {
        'en': Strings.emailHint,
        'es': 'test@test.com',
      } +
      {
        'en': Strings.signInWithEmailLink,
        'es': 'Inicia sesión',
      } +
      {
        'en': Strings.invalidEmailErrorText,
        'es': 'El correo electrónico no es válido',
      } +
      {
        'en': Strings.inspiredText,
        'es': 'se inspiró en la forma en que su familia comparte',
      } +
      {
        'en': Strings.fromYouthAndOtherThings,
        'es':
            'de su juventud, escuela secundaria, aventuras, matrimonio, militares, hijos, etc.',
      } +
      {
        'en': Strings.memoriesText,
        'es': 'recuerdos de fotos',
      } +
      {
        'en': Strings.youCanShare,
        'es':
            'para que ahora puedas compartir con otras personas de tu familia.',
      } +
      {
        'en': Strings.submitEmailAddressLink,
        'es':
            'Envíe su dirección de correo electrónico para recibir un enlace de activación.',
      } +
      {
        'en': Strings.checkYourEmail,
        'es': 'Revisa tu correo electrónico',
      } +
      {
        'en': Strings.activationLinkSent,
        'es': 'Hemos enviado un enlace de activación',
      } +
      {
        'en': Strings.errorSendingEmail,
        'es': 'Error al enviar correo electrónico',
      } +
      {
        'en': Strings.sendActivationLink,
        'es': 'Enviar enlace',
      } +
      {
        'en': Strings.activationLinkError,
        'es': 'Error de activación por correo electrónico',
      } +
      {
        'en': Strings.submitEmailAgain,
        'es':
            'Por favor, envíe su dirección de correo electrónico de nuevo para recibir un nuevo enlace de activación.',
      } +
      {
        'en': Strings.userAlreadySignedIn,
        'es': 'Recibió un enlace de activación, pero ya ha iniciado sesión.',
      } +
      {
        'en': Strings.isNotSignInWithEmailLinkMessage,
        'es': 'Enlace de activación no válido',
      } +
      {
        'en': Strings.toolTipFAB,
        'es': 'Añadir historia',
      } +
      {
        'en': Strings.storiesTabName,
        'es': 'Historias',
      } +
      {
        'en': Strings.friendsTabName,
        'es': 'Usuarios',
      } +
      {
        'en': Strings.noticesTabName,
        'es': 'Avisos',
      } +
      {
        'en': Strings.profileTabName,
        'es': 'Perfil',
      } +
      {
        'en': Strings.filterText,
        'es': 'Filtrar por nombre o hogar',
      } +
      {
        'en': Strings.typeUserButtonFriends,
        'es': 'Amigos',
      } +
      {
        'en': Strings.typeUserButtonUsers,
        'es': 'Otros',
      } +
      {
        'en': Strings.typeUserButtonMe,
        'es': 'Yo',
      } +
      {
        'en': Strings.requestFriendship,
        'es': '¿Pedir amistad?',
      } +
      {
        'en': Strings.cancelFriendship,
        'es': '¿Acabar con la amistad?',
      } +
      {
        'en': Strings.quitFriend,
        'es': '¿Salir?',
      } +
      {
        'en': Strings.pending,
        'es': 'Pendiente',
      } +
      {
        'en': Strings.newFriend,
        'es': '¿Amigo?',
      } +
      {
        'en': Strings.rejectFriendshipRequest,
        'es': '¿Rechazar la solicitud de amistad?',
      } +
      {
        'en': Strings.approveFriendshipRequest,
        'es': '¿Aprobar la solicitud de amistad?',
      } +
      {
        'en': Strings.approveFriendButton,
        'es': 'Aprobar',
      } +
      {
        'en': Strings.rejectFriendButton,
        'es': 'Rechazar',
      } +
      {
        'en': Strings.viewCommentButton,
        'es': 'Vista',
      } +
      {
        'en': Strings.clearCommentButton,
        'es': 'Claro',
      } +
      {
        'en': Strings.profilePageName,
        'es': 'Perfil',
      } +
      {
        'en': Strings.galleryImageButton,
        'es': 'Galería',
      } +
      {
        'en': Strings.cameraImageButton,
        'es': 'Cámara',
      } +
      {
        'en': Strings.imagePlaceholderText,
        'es': 'Su marcador de posición de imagen',
      } +
      {
        'en': Strings.yourPictureSelection,
        'es': 'Su selección de imagen',
      } +
      {
        'en': Strings.yourFullNameText,
        'es': 'Introduzca su nombre completo',
      } +
      {
        'en': Strings.yourFullNameLabel,
        'es': 'Nombre',
      } +
      {
        'en': Strings.yourHomeText,
        'es': 'Ingrese su ciudad, estado',
      } +
      {
        'en': Strings.yourHomeLabel,
        'es': 'Casa',
      } +
      {
        'en': Strings.nameEmptyMessage,
        'es': 'Por favor, introduzca su nombre',
      } +
      {
        'en': Strings.homeEmptyMessage,
        'es': 'Por favor, ingrese a su casa',
      } +
      {
        'en': Strings.imagePlaceholder,
        'es': 'Marcador de posición de imagen',
      } +
      {
        'en': Strings.imageSelection,
        'es': 'Selección de imagen',
      } +
      {
        'en': Strings.currentAudio,
        'es': 'Audio',
      } +
      {
        'en': Strings.audioControls,
        'es': 'Record Story',
      } +
      {
        'en': Strings.pictureGallery,
        'es': 'Galería',
      } +
      {
        'en': Strings.pictureCamera,
        'es': 'Cámara',
      } +
      {
        'en': Strings.audioStop,
        'es': 'Parada',
      } +
      {
        'en': Strings.audioPlay,
        'es': 'Jugar',
      } +
      {
        'en': Strings.audioRecord,
        'es': 'grabar',
      } +
      {
        'en': Strings.audioPause,
        'es': 'Pausa',
      } +
      {
        'en': Strings.audioResume,
        'es': 'Reanudar',
      } +
      {
        'en': Strings.audioClear,
        'es': 'Claro',
      } +
      {
        'en': Strings.mustAcceptPermissions,
        'es': 'Debe aceptar permisos',
      } +
      {
        'en': Strings.addTagHere,
        'es': 'Añadir etiqueta aquí',
      } +
      {
        'en': Strings.showAllTags,
        'es': 'Mostrar todas las etiquetas',
      } +
      {
        'en': Strings.deleteStoryButton,
        'es': '¿Eliminar historia?',
      } +
      {
        'en': Strings.incrementToolTip,
        'es': 'Añadir historia',
      } +
      {
        'en': Strings.gridStoryShowCommentsText
            .zero('No comments')
            .one('One comment')
            .many('%d comments'),
        'es': 'Comentarios'
            .zero('Sin comentarios')
            .one('Uno comentarios')
            .many('%d comentarios'),
      } +
      {
        'en': Strings.gridStoryShowTagsText
            .zero('No tags')
            .one('One tag')
            .many('%d tags'),
        'es': 'Comentarios'
            .zero('No etiquetas')
            .one('Uno etiquetas')
            .many('%d etiquetas'),
      } +
      {
        'en': Strings.friendRequest,
        'es': 'Solicitud de amigo',
      } +
      {
        'en': Strings.commentRequest,
        'es': 'Nuevo comentario',
      } +
      {
        'en': Strings.developerMenu,
        'es': 'Menú Desarrollador',
      } +
      {
        'en': Strings.authenticationType,
        'es': 'Tipo de autenticación',
      } +
      {
        'en': Strings.firebase,
        'es': 'Firebase',
      } +
      {
        'en': Strings.mock,
        'es': 'Simulacro',
      } +
      {
        'en': Strings.recordAComment,
        'es': 'Grabar un comentario',
      } +
      {
        'en': Strings.commentsLabel,
        'es': 'Ver Comentarios',
      } +
      {
        'en': Strings.storyLabel,
        'es': 'Ver Historia',
      } +
      {
        'en': Strings.deleteStoryQuestion,
        'es': '¿Eliminar historia?',
      } +
      {
        'en': Strings.dateLabel,
        'es': 'Fecha',
      } +
      {
        'en': Strings.tagsLabel,
        'es': 'Etiquetas',
      } +
      {
        'en': Strings.searchByTagsHint,
        'es': 'Buscar por etiqueta',
      } +
      {
        'en': Strings.deleteComment,
        'es': 'Eliminar',
      } +
      {
        'en': Strings.hideComment,
        'es': 'Ocultar',
      } +
      {
        'en': Strings.showComment,
        'es': 'Mostrar',
      } +
      {
        'en': Strings.languages,
        'es': 'Idiomas',
      } +
      {
        'en': Strings.saved,
        'es': 'Guardar exitoso',
      } +
      {
        'en': Strings.deleted,
        'es': 'Eliminar exitoso',
      };
  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(int value) => localizePlural(value, this, _t);
  String version(Object modifier) => localizeVersion(modifier, this, _t);
  Map<String, String> allVersions() => localizeAllVersions(this, _t);
}
