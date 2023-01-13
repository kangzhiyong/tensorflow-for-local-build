"""Provides the repository macro to import TFRT."""

load("//third_party:repo.bzl", "tf_http_archive", "tf_mirror_urls")

def repo():
    """Imports TFRT."""

    # Attention: tools parse and update these lines.
#     TFRT_COMMIT = "4ce3e4da2e21ae4dfcee9366415e55f408c884ec"
#     TFRT_SHA256 = "a0aa5ab0af90684db7a1cf8dd3d21081e44ef54eb9a1b6b9bb8b051d3ed25a67"

#     tf_http_archive(
#         name = "tf_runtime",
#         sha256 = TFRT_SHA256,
#         strip_prefix = "runtime-{commit}".format(commit = TFRT_COMMIT),
#         urls = tf_mirror_urls("https://github.com/tensorflow/runtime/archive/{commit}.tar.gz".format(commit = TFRT_COMMIT)),
#         # A patch file can be provided for atomic commits to both TF and TFRT.
#         # The job that bumps the TFRT_COMMIT also resets patch_file to 'None'.
#         patch_file = None,
#     )
    # Attention: tools parse and update these lines.
    TFRT_COMMIT = "4dc142c3747405b077b7d041174a1310918098be"
    TFRT_SHA256 = "ba7a06b0b6333edcc525dad5d0269cfbb0a2954239336c04d30451533b06ad1f"

    tf_http_archive(
        name = "tf_runtime",
        sha256 = TFRT_SHA256,
        strip_prefix = "runtime-{commit}".format(commit = TFRT_COMMIT),
        urls = ["https://storage.googleapis.com/mirror.tensorflow.org/github.com/tensorflow/runtime/archive/4dc142c3747405b077b7d041174a1310918098be.tar.gz",
                "https://github.com/tensorflow/runtime/archive/4dc142c3747405b077b7d041174a1310918098be.tar.gz",
                "http://127.0.0.1:8080/tensorflow/runtime-4dc142c3747405b077b7d041174a1310918098be.tar.gz"],
        # A patch file can be provided for atomic commits to both TF and TFRT.
        # The job that bumps the TFRT_COMMIT also resets patch_file to 'None'.
        patch_file = None,
    )
