/**
 * @providesModule RNAdalPlugin
 * @flow
 */

function reject() {
	return Promise.reject(new Error('Not Supported by react-native-ms-adal on UWP'));
}
const getValidMSAdalToken = reject;
const MSAdalLogin = reject;
const MSAdalLogout = reject;
export {
    getValidMSAdalToken,
    MSAdalLogin,
    MSAdalLogout,
};
export {
    MSAdalAuthenticationContext
} from "./MSAdal";
