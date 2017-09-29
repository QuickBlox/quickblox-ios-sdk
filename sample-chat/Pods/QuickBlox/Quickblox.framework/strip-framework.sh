# Stripping framework only for archive
if [ "$ACTION" = "install" ]; then

    FRAMEWORK_NAME="Quickblox"
    SCRIPT_FILE_NAME="strip-framework.sh"

    # Set working directory to product’s embedded frameworks
    cd "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/${FRAMEWORK_NAME}.framework"

    # Get architectures for current file
    ARCHS="$(lipo -info "${FRAMEWORK_NAME}" | rev | cut -d ':' -f1 | rev)"
    for ARCH in $ARCHS; do
        if ! [[ "${VALID_ARCHS}" == *"$ARCH"* ]]; then
        # Strip non-valid architectures in-place
        lipo -remove "$ARCH" -output "$FRAMEWORK_NAME" "$FRAMEWORK_NAME" || exit 1
        fi
    done

    echo "Framework was successfully stripped with unsupported architectures"

fi

# Removing script from framework folder
if [ -f ${SCRIPT_FILE_NAME} ]; then
    rm -rf "${SCRIPT_FILE_NAME}"
fi
