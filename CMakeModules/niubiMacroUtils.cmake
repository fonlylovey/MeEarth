

MACRO(NIUBI_SETUP_SELECT)

    IF( SELECT_PLATFORM EQUAL 1)#win32
		ADD_DEFINITIONS(-DNIUBI_USE_WINDOWS=1)
	ENDIF()
    IF( SELECT_PLATFORM EQUAL 2)#linux x11
		ADD_DEFINITIONS(-DNIUBI_USE_LINUX=1)
	ENDIF()
    IF( SELECT_PLATFORM EQUAL 3)#flascc
		# ADD_DEFINITIONS(-DNIUBI_USE_LINUX=1)
	ENDIF()
    IF( SELECT_PLATFORM EQUAL 4)#emc
		ADD_DEFINITIONS(-DNIUBI_USE_EMC=1)
	ENDIF()
    IF( SELECT_PLATFORM EQUAL 5)#android
        ADD_DEFINITIONS( -DNIUBI_USE_ANDROID=1)
	ENDIF()
    
    IF( SELECT_GRAPHICS_INTERFACE EQUAL 1)#opengl
		ADD_DEFINITIONS(-DNIUBI_USE_GL_2=1)
	ENDIF()
    IF( SELECT_GRAPHICS_INTERFACE EQUAL 2)#dx9
		ADD_DEFINITIONS(-DNIUBI_USE_DX9=1)
	ENDIF()
    IF( SELECT_GRAPHICS_INTERFACE EQUAL 3)#gles 1
		ADD_DEFINITIONS(-DNIUBI_USE_GLES1=1)
	ENDIF()
    IF( SELECT_GRAPHICS_INTERFACE EQUAL 4)#gles 2
		ADD_DEFINITIONS(-DNIUBI_USE_GLES2=1)
	ENDIF()
    
ENDMACRO(NIUBI_SETUP_SELECT)


MACRO(NIUBI_LINK_SELECT_PULGINS)
IF(BUILD_STATIC_LIBRAY)
    SET(LINK_SELECT_LIB)

    IF(SELECT_PLATFORM EQUAL 1)
            SET(LINK_SELECT_LIB ${LINK_SELECT_LIB} NativeWindow_win32 )
        IF(SELECT_GRAPHICS_INTERFACE EQUAL 1)
            SET(LINK_SELECT_LIB ${LINK_SELECT_LIB} GraphicsContext_wgl Renderer_gl_2_0)
        ENDIF()
        IF(SELECT_GRAPHICS_INTERFACE EQUAL 2)
            SET(LINK_SELECT_LIB ${LINK_SELECT_LIB} GraphicsContext_dx9 Renderer_dx_9)
        ENDIF()
        IF(SELECT_GRAPHICS_INTERFACE EQUAL 3)
            SET(LINK_SELECT_LIB ${LINK_SELECT_LIB} GraphicsContext_egl_mali Renderer_gles_1_x ${MALI_EGL_LIBRARY})
        ENDIF()
        IF(SELECT_GRAPHICS_INTERFACE EQUAL 4)
            SET(LINK_SELECT_LIB ${LINK_SELECT_LIB} GraphicsContext_egl_mali Renderer_gles_2_x ${MALI_EGL_LIBRARY} ${MALI_GLES_2_LIBRARY})
        ENDIF()
    ENDIF()
    
    IF(SELECT_PLATFORM EQUAL 2)
        SET(LINK_SELECT_LIB Renderer_gl_2_0 GraphicsContext_glx NativeWindow_x11 )
    ENDIF()
    
    IF( SELECT_PLATFORM EQUAL 3)
		# ADD_DEFINITIONS(-DNIUBI_USE_EMC=1)
	ENDIF()
    
    IF( SELECT_PLATFORM EQUAL 4)
		SET(LINK_SELECT_LIB NativeWindow_emc )
        SET(LINK_SELECT_LIB ${LINK_SELECT_LIB} GraphicsContext_egl_emc Renderer_gles_1_x)
	ENDIF()
    
    IF(SELECT_PLATFORM EQUAL 5)
        #SET(LINK_SELECT_LIB Renderer_gl_2_0 GraphicsContext_glx NativeWindow_x11 )
    ENDIF()
    
    TARGET_LINK_LIBRARIES(${NIUBI_SETUP_TARGET_NAME} ${LINK_SELECT_LIB})   
ENDIF(BUILD_STATIC_LIBRAY)  
ENDMACRO(NIUBI_LINK_SELECT_PULGINS)

    
MACRO(NIUBI_SETUP_FLAGS)

    IF(CYGWIN)
    # set(CMAKE_CXX_FLAGS "-fpermissive -std=c++0x")
    # set(CMAKE_CXX_FLAGS "-fpermissive")
    SET(OSG_AGGRESSIVE_WARNING_FLAGS "-Wall -Wparentheses -Wno-long-long -Wno-import -pedantic -Wreturn-type -Wmissing-braces -Wunknown-pragmas -Wunused -fpermissive")
    set(CMAKE_CXX_FLAGS ${OSG_AGGRESSIVE_WARNING_FLAGS})
    ENDIF(CYGWIN)
    
    
    IF(UNIX)
        set(CMAKE_CXX_FLAGS "-Wunused")
    ENDIF(UNIX)
    
    IF(ANDROID)
        set(CMAKE_CXX_FLAGS "-frtti -fexceptions -fpermissive")
    ENDIF(ANDROID)
    
ENDMACRO(NIUBI_SETUP_FLAGS)

#input NIUBI_SETUP_TARGET_NAME
#input NIUBI_SETUP_SOURCES
#input NIUBI_SETUP_HEADERS
MACRO(NIUBI_SETUP_LIBRARY NO_SOURCE_GROUP)

	# IF( ${NO_SOURCE_GROUP} EQUAL ON)
		SET(HEADERS_GROUP "Header Files")
		SOURCE_GROUP( ${HEADERS_GROUP} FILES ${NIUBI_SETUP_HEADERS})
	# ENDIF

    NIUBI_SETUP_FLAGS()
    NIUBI_SETUP_SELECT()

    
    SET( OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin )
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET(OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin64) #64bit
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")

    
	IF(BUILD_STATIC_LIBRAY)
		ADD_DEFINITIONS(-DNIUBI_LIBRARY_STATIC)
		ADD_LIBRARY(${NIUBI_SETUP_TARGET_NAME} STATIC ${NIUBI_SETUP_HEADERS} ${NIUBI_SETUP_SOURCES})
	ELSE(BUILD_STATIC_LIBRAY)
		# ADD_DEFINITIONS(-DNIUBI_LIBRARY)
		SET (LIBRARY_TAG  -D${NIUBI_SETUP_TARGET_NAME}_LIBRARY)
		STRING(TOUPPER ${LIBRARY_TAG} LIBRARY_TAG )
		# MESSAGE(${LIBRARY_TAG})
		ADD_DEFINITIONS(${LIBRARY_TAG})
		ADD_LIBRARY(${NIUBI_SETUP_TARGET_NAME} SHARED ${NIUBI_SETUP_HEADERS} ${NIUBI_SETUP_SOURCES})
	ENDIF(BUILD_STATIC_LIBRAY)
	
	
	SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})

    # IF(MSVC_IDE)
	# IF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600)
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES  PREFIX "../")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES  IMPORT_PREFIX "../")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600)

	# IF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE "../../bin")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG "../../bin")
		## SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES IMPORT_PREFIX "../")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE "../../lib")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG "../../lib")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
    # ENDIF(MSVC_IDE)
    
    SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES FOLDER "Core")
    
	# TARGET_LINK_LIBRARIES(${NIUBI_SETUP_TARGET_NAME}
		# opengl32 glu32 
        # ${OPENGL_LIBRARIES}
		# ${WOSG_LIBRARY_ALL}
		# ${WOSG_LIBRARY_ALL_PLUGINS}
		# ${WOSG_LIBRARY_ALL_DEPEND}
		# )

ENDMACRO(NIUBI_SETUP_LIBRARY)


#input NIUBI_SETUP_TARGET_NAME
#input NIUBI_SETUP_HEADERS
MACRO(NIUBI_SETUP_INSTALL)

	SET(INSTALL_INCDIR include)
	SET(INSTALL_BINDIR bin)
	IF(WIN32)
		SET(INSTALL_LIBDIR bin)
		SET(INSTALL_ARCHIVEDIR lib)
	ELSE(WIN32)
		SET(INSTALL_LIBDIR lib${LIB_POSTFIX})
		SET(INSTALL_ARCHIVEDIR lib${LIB_POSTFIX})
	ENDIF(WIN32)

	INSTALL(
		TARGETS ${NIUBI_SETUP_TARGET_NAME}
		RUNTIME DESTINATION ${INSTALL_BINDIR}
		LIBRARY DESTINATION ${INSTALL_LIBDIR}
		ARCHIVE DESTINATION ${INSTALL_ARCHIVEDIR}
	)

ENDMACRO(NIUBI_SETUP_INSTALL)

#input NIUBI_SETUP_TARGET_NAME
#input NIUBI_SETUP_HEADERS
MACRO(NIUBI_SETUP_INSTALL_INCLUDE)

	INSTALL(
		FILES       ${NIUBI_SETUP_HEADERS}
		DESTINATION ${INSTALL_INCDIR}/${NIUBI_SETUP_TARGET_NAME}
	)

ENDMACRO(NIUBI_SETUP_INSTALL_INCLUDE)


MACRO(NIUBI_SETUP_DOCUMENT)


ENDMACRO(NIUBI_SETUP_DOCUMENT)



#input NIUBI_SETUP_TARGET_NAME
#input NIUBI_SETUP_SOURCES
#input NIUBI_SETUP_HEADERS
MACRO(NIUBI_SETUP_PLUGINS NO_SOURCE_GROUP)

	# INCLUDE_DIRECTORIES(AFTER ${WOSG_INCLUDE_DIR})
	# INCLUDE_DIRECTORIES(AFTER ../../common)

	# IF( ${NO_SOURCE_GROUP} EQUAL ON)
		SET(HEADERS_GROUP "Header Files")
		SOURCE_GROUP( ${HEADERS_GROUP} FILES ${NIUBI_SETUP_HEADERS})
	# ENDIF


    
    NIUBI_SETUP_FLAGS()
    NIUBI_SETUP_SELECT()
    
    
    SET( OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin )
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET(OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin64) #64bit
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    
    
	IF(BUILD_STATIC_LIBRAY)
		ADD_DEFINITIONS(-DNIUBI_LIBRARY_STATIC)
		ADD_LIBRARY(${NIUBI_SETUP_TARGET_NAME} STATIC ${NIUBI_SETUP_HEADERS} ${NIUBI_SETUP_SOURCES})
	ELSE(BUILD_STATIC_LIBRAY)
		ADD_DEFINITIONS(-DNIUBI_PULGINS_LIBRARY)
		ADD_LIBRARY(${NIUBI_SETUP_TARGET_NAME} SHARED ${NIUBI_SETUP_HEADERS} ${NIUBI_SETUP_SOURCES})
	ENDIF(BUILD_STATIC_LIBRAY)
	
	
	SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})

    # IF(MSVC_IDE)
	# IF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600)
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES  PREFIX "../")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES  IMPORT_PREFIX "../")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600)
	# IF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES "RUNTIME_OUTPUT_DIRECTORY_RELEASE" "../../../bin")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES "RUNTIME_OUTPUT_DIRECTORY_DEBUG"   "../../../bin")
		## SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES IMPORT_PREFIX "../")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE "../../../lib")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG   "../../../lib")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
    # ENDIF(MSVC_IDE)
    
    SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES FOLDER "Plugins")
    
	TARGET_LINK_LIBRARIES(${NIUBI_SETUP_TARGET_NAME}
		# opengl32 glu32 
        # ${OPENGL_LIBRARIES}
		# ${WOSG_LIBRARY_ALL}
		# ${WOSG_LIBRARY_ALL_PLUGINS}
		# ${WOSG_LIBRARY_ALL_DEPEND}
		nbPlugins
		)

ENDMACRO(NIUBI_SETUP_PLUGINS)


#input NIUBI_SETUP_TARGET_NAME
#input NIUBI_SETUP_SOURCES
#input NIUBI_SETUP_HEADERS
MACRO(NIUBI_SETUP_EXECUTABLE NO_SOURCE_GROUP)

	# INCLUDE_DIRECTORIES(AFTER ${WOSG_INCLUDE_DIR})
	# INCLUDE_DIRECTORIES(AFTER ../../common)

	# IF( ${NO_SOURCE_GROUP} EQUAL ON)
		SET(HEADERS_GROUP "Header Files")
		SOURCE_GROUP( ${HEADERS_GROUP} FILES ${NIUBI_SETUP_HEADERS})
	# ENDIF
    
    IF( EMSCRIPTEN )
        SET(CMAKE_EXECUTABLE_SUFFIX ".html")
    ENDIF( EMSCRIPTEN )

    NIUBI_SETUP_FLAGS()
    NIUBI_SETUP_SELECT()
    
    
    SET( OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin )
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET(OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin64) #64bit
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    
    
	IF(BUILD_STATIC_LIBRAY)
		ADD_DEFINITIONS(-DNIUBI_LIBRARY_STATIC)
	ENDIF(BUILD_STATIC_LIBRAY)
    
    # IF(ANDROID)
        # ADD_DEFINITIONS( -DNIUBI_ENTRY_ANDORID_NDK_NATIVE)
        # ADD_LIBRARY(${NIUBI_SETUP_TARGET_NAME} SHARED ${NIUBI_SETUP_HEADERS} ${NIUBI_SETUP_SOURCES})
    # ELSE(ANDROID)
        ADD_EXECUTABLE(${NIUBI_SETUP_TARGET_NAME} ${NIUBI_SETUP_HEADERS} ${NIUBI_SETUP_SOURCES})
    # ENDIF(ANDROID)
	
	SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES PROJECT_LABEL "${NIUBI_SETUP_TARGET_NAME}")
	SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES DEBUG_POSTFIX "${CMAKE_DEBUG_POSTFIX}")
	SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES OUTPUT_NAME ${NIUBI_SETUP_TARGET_NAME})
	# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})

    # IF(MSVC_IDE)
	# IF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600) #1600 is vs2010
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES  PREFIX "../")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600)
	# IF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES "RUNTIME_OUTPUT_DIRECTORY_RELEASE" "../../bin")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES "RUNTIME_OUTPUT_DIRECTORY_DEBUG" "../../bin")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
    # ENDIF(MSVC_IDE)
    
    SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES FOLDER "App")
    
    # NIUBI_LINK_SELECT_PULGINS()
    
	# TARGET_LINK_LIBRARIES(${NIUBI_SETUP_TARGET_NAME}
		# opengl32 glu32 
        # ${OPENGL_LIBRARIES}
        # ${OPENGL_gl_LIBRARY}
        # /usr/lib/libGL.dll.a
		# ${WOSG_LIBRARY_ALL}
		# ${WOSG_LIBRARY_ALL_PLUGINS}
		# ${WOSG_LIBRARY_ALL_DEPEND}
		# )
        
    # MESSAGE( WARRING " " ${OPENGL_LIBRARIES})

ENDMACRO(NIUBI_SETUP_EXECUTABLE)


#input NIUBI_SETUP_TARGET_NAME
#input NIUBI_SETUP_SOURCES
#input NIUBI_SETUP_HEADERS
MACRO(NIUBI_SETUP_DYNAMIC_LIBRARY NO_SOURCE_GROUP)

	# IF( ${NO_SOURCE_GROUP} EQUAL ON)
		SET(HEADERS_GROUP "Header Files")
		SOURCE_GROUP( ${HEADERS_GROUP} FILES ${NIUBI_SETUP_HEADERS})
	# ENDIF

    NIUBI_SETUP_FLAGS()
    NIUBI_SETUP_SELECT()
    
    SET( OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin )
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET(OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin64) #64bit
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
    SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")

    # ADD_DEFINITIONS(-DNIUBI_LIBRARY)
    SET (LIBRARY_TAG  -D${NIUBI_SETUP_TARGET_NAME}_LIBRARY)
    STRING(TOUPPER ${LIBRARY_TAG} LIBRARY_TAG )
    # MESSAGE(${LIBRARY_TAG})
    ADD_DEFINITIONS(${LIBRARY_TAG})
    ADD_LIBRARY(${NIUBI_SETUP_TARGET_NAME} SHARED ${NIUBI_SETUP_HEADERS} ${NIUBI_SETUP_SOURCES})

	SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})

    # IF(MSVC_IDE)
	# IF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600)
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES  PREFIX "../")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES  IMPORT_PREFIX "../")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} LESS 1600)

	# IF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE "../../bin")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG "../../bin")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES IMPORT_PREFIX "../")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE "../../lib")
		# SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG "../../lib")
	# ENDIF(MSVC_IDE AND ${MSVC_VERSION} EQUAL 1600)
    # ENDIF(MSVC_IDE)
    
    SET_TARGET_PROPERTIES(${NIUBI_SETUP_TARGET_NAME} PROPERTIES FOLDER "Dll")

ENDMACRO(NIUBI_SETUP_DYNAMIC_LIBRARY)
