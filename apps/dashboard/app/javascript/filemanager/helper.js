export const APP_PREFIX = window.location.origin + '/' + window.location.href.split('/').slice(3,7).join('/')

export function file_link(path) {
    return APP_PREFIX + path
}