import 'package:i18n_extension/i18n_extension.dart';
import 'package:voiceClient/constants/strings.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

extension Localization on String {
  //
  static final _t = Translations('en') +
      {
        'en': Strings.MFV,
        'es': 'Mi Voz Familiar',
      } +
      {
        'en': Strings.ok,
        'es': 'Okay',
      } +
      {
        'en': Strings.yes,
        'es': 'Si',
      } +
      {
        'en': Strings.areYouSure,
        'es': '¿Estas segura?',
      } +
      {
        'en': Strings.cancel,
        'es': 'Cancelar',
      } +
      {
        'en': Strings.noResults,
        'es': 'No hay resultados',
      } +
      {
        'en': Strings.upload,
        'es': 'Subir',
      } +
      {
        'en': Strings.loadMore,
        'es': 'Carga más',
      } +
      {
        'en': Strings.logout,
        'es': 'Cerrar sesión',
      } +
      {
        'en': Strings.logoutAreYouSure,
        'es': '¿Estás seguro de que quieres cerrar sesión?',
      } +
      {
        'en': Strings.usLocale,
        'es': '¿Cambiar a Inglés?',
      } +
      {
        'en': Strings.esLocale,
        'es': '¿Cambiar al español?',
      } +
      {
        'en': Strings.logoutFailed,
        'es': 'Cierre de sesión fallido',
      } +
      {
        'en': Strings.signIn,
        'es': 'Registrarse',
      } +
      {
        'en': Strings.emailLabel,
        'es': 'Email',
      } +
      {
        'en': Strings.emailHint,
        'es': 'test@test.com',
      } +
      {
        'en': Strings.signInWithEmailLink,
        'es': 'Iniciar sesión',
      } +
      {
        'en': Strings.invalidEmailErrorText,
        'es': 'El correo electrónico es invalido',
      } +
      {
        'en': Strings.inspiredText,
        'es': ' se inspiró en la forma en que comparte tu familia ',
      } +
      {
        'en': Strings.fromYouthAndOtherThings,
        'es':
            ' desde su juventud, escuela secundaria, aventuras, matrimonio, militares, niños, etc.',
      } +
      {
        'en': Strings.memoriesText,
        'es': 'recuerdos de fotos',
      } +
      {
        'en': Strings.firebase,
        'es': 'Firebase',
      } +
      {
        'en': Strings.youCanShare,
        'es':
            'para que ahora pueda compartir con otros miembros de su familia.',
      } +
      {
        'en': Strings.submitEmailAddressLink,
        'es':
            'Envíe su dirección de correo electrónico para recibir un enlace de activación.',
      } +
      {
        'en': Strings.checkYourEmail,
        'es': 'Consultar su correo electrónico',
      } +
      {
        'en': Strings.activationLinkSent,
        'es': 'Nosotros hemos enviado un enlace de activación',
      } +
      {
        'en': Strings.errorSendingEmail,
        'es': 'Error al enviar correo electrónico',
      } +
      {
        'en': Strings.sendActivationLink,
        'es': 'Enviar enlace de activación',
      } +
      {
        'en': Strings.activationLinkError,
        'es': 'Error de activación de correo electrónico',
      } +
      {
        'en': Strings.submitEmailAgain,
        'es':
            'Por favor envíe su dirección de correo electrónico nuevamente para recibir un nuevo enlace de activación',
      } +
      {
        'en': Strings.userAlreadySignedIn,
        'es': 'Recibió un enlace de activación pero ya inició sesión',
      } +
      {
        'en': Strings.isNotSignInWithEmailLinkMessage,
        'es': 'Enlace de activación inválido',
      } +
      {
        'en': Strings.toolTipFAB,
        'es': 'Añadir historia',
      } +
      {
        'en': Strings.storiesTabName,
        'es': 'Cuentos',
      } +
      {
        'en': Strings.friendsTabName,
        'es': 'Amigos',
      } +
      {
        'en': Strings.noticesTabName,
        'es': 'Aviso',
      } +
      {
        'en': Strings.profileTabName,
        'es': 'Retrato',
      } +
      {
        'en': Strings.filterText,
        'es': 'Filtrar por nombre o casa',
      } +
      {
        'en': Strings.typeUserButtonFriends,
        'es': 'Amigos',
      } +
      {
        'en': Strings.typeUserButtonUsers,
        'es': 'Los usuarios',
      } +
      {
        'en': Strings.typeUserButtonMe,
        'es': 'Yo',
      } +
      {
        'en': Strings.requestFriendship,
        'es': 'Amistad?',
      } +
      {
        'en': Strings.cancelFriendship,
        'es': '¿Fin?',
      } +
      {
        'en': Strings.quitFriend,
        'es': '¿Salir amigo?',
      } +
      {
        'en': Strings.pending,
        'es': 'Pendiente',
      } +
      {
        'en': Strings.newFriend,
        'es': '¿Nuevo amigo?',
      } +
      {
        'en': Strings.rejectFriendshipRequest,
        'es': '¿Rechazar solicitud de amistad?',
      } +
      {
        'en': Strings.approveFriendshipRequest,
        'es': '¿Aprobar solicitud de amistad?',
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
        'en': Strings.galleryImageButton,
        'es': 'Galería',
      } +
      {
        'en': Strings.profilePageName,
        'es': 'Perfil',
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
        'es': 'Su selección de imágenes',
      } +
      {
        'en': Strings.yourFullNameText,
        'es': 'Ingrese su nombre completo',
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
        'es': 'Hogar',
      } +
      {
        'en': Strings.yourBirthText,
        'es': 'Año de nacimiento',
      } +
      {
        'en': Strings.yourBirthLabel,
        'es': 'Año de su nacimiento',
      } +
      {
        'en': Strings.nameEmptyMessage,
        'es': 'Por favor, escriba su nombre',
      } +
      {
        'en': Strings.homeEmptyMessage,
        'es': 'Por favor ingrese su casa',
      } +
      {
        'en': Strings.birthEmptyMessage,
        'es': 'Por favor ingrese un año',
      } +
      {
        'en': Strings.birthValidationMessage,
        'es': 'Por favor, introduzca un año válido',
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
        'es': 'Audio Actual',
      } +
      {
        'en': Strings.audioControls,
        'es': 'Historia Récord',
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
        'es': 'Detener',
      } +
      {
        'en': Strings.audioPlay,
        'es': 'Jugar',
      } +
      {
        'en': Strings.audioRecord,
        'es': 'Grabar',
      } +
      {
        'en': Strings.audioPause,
        'es': 'Pausa',
      } +
      {
        'en': Strings.audioResume,
        'es': 'Continuar',
      } +
      {
        'en': Strings.audioClear,
        'es': 'Reiniciar',
      } +
      {
        'en': Strings.mustAcceptPermissions,
        'es': 'Debes aceptar permisos',
      } +
      {
        'en': Strings.addTagHere,
        'es': 'Agregar etiqueta aquí',
      } +
      {
        'en': Strings.showAllTags,
        'es': 'Mostrar todas las etiquetas',
      } +
      {
        'en': Strings.incrementToolTip,
        'es': 'Añadir historia',
      } +
      {
        'en': Strings.friendRequest,
        'es': 'Solicitud de amistad',
      } +
      {
        'en': Strings.recordAComment,
        'es': 'Grabar un comentario',
      } +
      {
        'en': Strings.commentsLabel,
        'es': 'Comentarios',
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
        'en': Strings.dateLabel,
        'es': 'Fecha',
      } +
      {
        'en': Strings.tagsLabel,
        'es': 'Etiquetas',
      } +
      {
        'en': Strings.deleteComment,
        'es': 'Eliminar',
      } +
      {
        'en': Strings.hideComment,
        'es': 'Esconder',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);

  Map<String, String> allVersions() => localizeAllVersions(this, _t);
}
