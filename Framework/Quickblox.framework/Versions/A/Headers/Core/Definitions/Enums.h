/*
 *  Enums.h
 *  BaseService
 *
 *
 */

enum BaseServiceErrorType 
{
	BaseServiceErrorTypeUnknown = 0,
	BaseServiceErrorTypeValidation,
	BaseServiceErrorTypeParse,
	BaseServiceErrorTypeConnection,
	BaseServiceErrorTypeServer
};

enum RestMethodKind
{
	RestMethodKindDELETE = 1,
	RestMethodKindGET,
	RestMethodKindPOST,
	RestMethodKindPUT,
    RestMethodKindHEAD
};

//QBASIHTTPRequest
enum RestResponseType
{
	RestResponseTypeXML,
    RestResponseTypeJavascript,
	RestResponseTypePlain,
	RestResponseTypeBinary,
	RestResponseTypeHTML,
    RestResponseTypeXHTML_XML,
	RestResponseTypeUnknown
}; 


enum RestAnswerKind
{
	RestAnswerKindUnknown,
	RestAnswerKindAccepted = 202,
	RestAnswerKindCreated = 201,
	RestAnswerKindNotFound = 404,
	RestAnswerKindOK = 200,
    RestAnswerKindBadRequest = 400,
	RestAnswerKindServerError = 500,
	RestAnswerKindUnAuthorized = 401,
	RestAnswerKindValidationFailed = 422
};

enum QBServerZone
{
	QBServerZoneStage,
	QBServerZoneDevelopment,
	QBServerZoneProduction
};

enum QBLogLevel
{
	QBLogLevelNothing,
	QBLogLevelDebug
};

enum RestRequestBuildStyle
{
	RestRequestBuildStyleParams,
	RestRequestBuildStyleMultipartFormData,
	RestRequestBuildStyleBinary
};

enum FileParameterType
{
	FileParameterTypePath,
	FileParameterTypeData
};

enum QBSessionType
{
    QBSessionTypeApplicationOnly,
    QBSessionTypeUser,
    QBSessionTypeSocialUser
};