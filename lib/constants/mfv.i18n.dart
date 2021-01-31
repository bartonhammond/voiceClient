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
        'en': Strings.typeUserButtonFamily,
        'es': 'Familia',
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
        'en': Strings.typeUserButtonBooks,
        'es': 'Libros',
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
        'es': '¿Dejar?',
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
        'en': Strings.homeLengthMessage,
        'es': 'La longitud de la casa debe ser mayor que 1',
      } +
      {
        'en': Strings.nameLengthMessage,
        'es': 'La longitud del nombre debe ser superior a 5',
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
        'en': Strings.deleteBookButton,
        'es': '¿Eliminar?',
      } +
      {
        'en': Strings.deleteBookTitle,
        'es': '¿Eliminar Libro?',
      } +
      {
        'en': Strings.manageBook,
        'es': '¿Gestionar?',
      } +
      {
        'en': Strings.bookName,
        'es': 'Libro',
      } +
      {
        'en': Strings.selectBookTitle,
        'es': 'Seleccionar libro',
      } +
      {
        'en': Strings.selectBookDescription,
        'es': 'Solo se puede seleccionar un libro',
      } +
      {
        'en': Strings.quitManagingTitle,
        'es': '¿Dejar de administrar?',
      } +
      {
        'en': Strings.writtenByTitle,
        'es': 'Autora',
      } +
      {
        'en': Strings.areYouSureYouWantToBan,
        'es': '¿Estás segura de prohibir?',
      } +
      {
        'en': Strings.banUser,
        'es': 'Prohibición',
      } +
      {
        'en': Strings.unbanUser,
        'es': 'Desban',
      } +
      {
        'en': Strings.removeTheBan,
        'es': '¿Eliminar la prohibición?',
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
        'en': Strings.messagesPageManage,
        'es': 'Gestionar',
      } +
      {
        'en': Strings.messagesPageViewStory,
        'es': 'Ver historia',
      } +
      {
        'en': Strings.commentRequest,
        'es': 'Comentario',
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
      } +
      {
        'en': Strings.reactionTableTitle,
        'es': 'Reacciones',
      } +
      {
        'en': Strings.reactionLike,
        'es': 'Gusta',
      } +
      {
        'en': Strings.reactionHaha,
        'es': 'HaHa',
      } +
      {
        'en': Strings.reactionJoy,
        'es': 'Alegría',
      } +
      {
        'en': Strings.reactionLove,
        'es': 'Amor',
      } +
      {
        'en': Strings.reactionSad,
        'es': 'Triste',
      } +
      {
        'en': Strings.reactionWow,
        'es': '¡Caray!',
      } +
      {
        'en': Strings.messagesPageMessage,
        'es': 'Mensaje',
      } +
      {
        'en': Strings.messagesPageDeleteMessage,
        'es': 'Borrar Mensaje',
      } +
      {
        'en': Strings.messagesPageMessageAll,
        'es': 'Todas',
      } +
      {
        'en': Strings.messagesPageMessageComments,
        'es': 'Comentarios',
      } +
      {
        'en': Strings.messagesPageMessageFriendRequests,
        'es': 'Peticiones de amistad',
      } +
      {
        'en': Strings.messagesPageMessageMessages,
        'es': 'Mensajes',
      } +
      {
        'en': Strings.storiesPageAll,
        'es': 'Todas',
      } +
      {
        'en': Strings.storiesPageFamily,
        'es': 'Familia',
      } +
      {
        'en': Strings.storiesPageFriends,
        'es': 'Amigos',
      } +
      {
        'en': Strings.storiesPageGlobal,
        'es': 'Global',
      } +
      {
        'en': Strings.storyPlayAudience,
        'es': 'Audiencia',
      } +
      {
        'en': Strings.storyPlayAttention,
        'es': 'Atención',
      } +
      {
        'en': Strings.storyPlayBookQuestion,
        'es': '¿Libro?',
      } +
      {
        'en': Strings.friendWidgetRecordMessage,
        'es': 'Grabar mensaje',
      } +
      {
        'en': Strings.friendWidgetMessage,
        'es': 'Mensaje',
      } +
      {
        'en': Strings.reactionTableMessage,
        'es': '¿Mensaje?',
      } +
      {
        'en': Strings.authDialogEmailEmpty,
        'es': 'El correo no puede estar vacío',
      } +
      {
        'en': Strings.authDialogCorrectEmailAddress,
        'es': 'Ingrese una dirección de correo correcta',
      } +
      {
        'en': Strings.authDialogPasswordEmpty,
        'es': 'La contraseña no puede estar vacía',
      } +
      {
        'en': Strings.authDialogPasswordLength,
        'es': 'La contraseña debe tener más de 6 y menos de 10',
      } +
      {
        'en': Strings.authDialogRegister,
        'es': 'Registrarse',
      } +
      {
        'en': Strings.authDialogRegisterSuccess,
        'es': 'Te has registrado exitosamente',
      } +
      {
        'en': Strings.authDialogRegisterFailure,
        'es': 'Ocurrió un error al registrarse ',
      } +
      {
        'en': Strings.authDialogEnterEmailPassword,
        'es': 'Ingrese correo electrónico y contraseña',
      } +
      {
        'en': Strings.authDialogSubmit,
        'es': 'Enviar',
      } +
      {
        'en': Strings.authDialogErrorSendingEmail,
        'es': 'Ocurrió un error al enviar el correo',
      } +
      {
        'en': Strings.authDialogPleaseEnterEmail,
        'es': 'Por favor ingrese su correo',
      } +
      {
        'en': Strings.authDialogLogin,
        'es': 'Iniciar sesión',
      } +
      {
        'en': Strings.authDialogLoginError,
        'es': 'Ocurrió un error al iniciar sesión',
      } +
      {
        'en': Strings.authDialogPassword,
        'es': 'Contraseña',
      } +
      {
        'en': Strings.authDialogShowPassword,
        'es': 'Mostrar contraseña',
      } +
      {
        'en': Strings.authDialogLoginOrRegister,
        'es': '¿Iniciar sesión o registrarse?',
      } +
      {
        'en': Strings.authDialogForgotPassword,
        'es': '¿Se te olvidó tu contraseña?',
      } +
      {
        'en': Strings.authDialogTermAndPrivacy,
        'es':
            'Al continuar, acepta nuestros Términos de uso y confirma que ha leído nuestra Política de privacidad.',
      } +
      {
        'en': Strings.landingUltimate,
        'es': 'La mejor experiencia familiar',
      } +
      {
        'en': Strings.landingUltimateSub,
        'es':
            'Mi Voz Familiar es una aplicación para que su familia grabe sus historias de audio para compartir con su familia para siempre',
      } +
      {
        'en': Strings.landingUltimateExplain,
        'es':
            'Descubre historias interesantes, algunas de las que nunca has oído hablar, contadas por tu propia familia.',
      } +
      {
        'en': Strings.landingFeatureOne,
        'es': 'ESCUCHA SUS HISTORIAS',
      } +
      {
        'en': Strings.landingFeatureOneSub,
        'es': 'Historias sobre imágenes que cuentan la historia familiar',
      } +
      {
        'en': Strings.landingFeatureOneExplain,
        'es':
            'Haga que el abuelo y el Grammy graben su historia para que los nietos la escuchen',
      } +
      {
        'en': Strings.landingFeatureTwo,
        'es': 'Toda la familia está invitada',
      } +
      {
        'en': Strings.landingFeatureTwoSub,
        'es': 'Todos pueden grabar, todas pueden escuchar.',
      } +
      {
        'en': Strings.landingFeatureTwoExplain,
        'es':
            'Todas las historias son de audio para que nadie tenga que escribir. Los comentarios también están en audio. ¡Y los mensajes también son de audio!',
      } +
      {
        'en': Strings.landingFeatureThree,
        'es': 'ENCUENTRA AMIGOS Y FAMILIA',
      } +
      {
        'en': Strings.landingFeatureThreeSub,
        'es': 'Distinguir a la familia por historias personales',
      } +
      {
        'en': Strings.landingFeatureThreeExplain,
        'es':
            'Puede buscar nuevos amigos utilizando sus nombres y su casa. Algunos amigos también pueden ser familiares',
      } +
      {
        'en': Strings.landingFeatureFour,
        'es': 'SELECCIONE RÁPIDAMENTE LAS FOTOS EXISTENTES O TOME UNA',
      } +
      {
        'en': Strings.landingFeatureFourSub,
        'es':
            'Puede usar las imágenes de la galería o usar la cámara para tomar una foto',
      } +
      {
        'en': Strings.landingFeatureFourExplain,
        'es':
            'Cuando selecciona su imagen, puede recortarla, ajustar su posición y volver a enmarcarla. Fácilmente también',
      } +
      {
        'en': Strings.proxyQuitManaging,
        'es': '¿Dejar de administrar?',
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(int value) => localizePlural(value, this, _t);
  String version(Object modifier) => localizeVersion(modifier, this, _t);
  Map<String, String> allVersions() => localizeAllVersions(this, _t);
}
