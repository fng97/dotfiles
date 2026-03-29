Convert a video file for inline playback on Zulip (MP4 H.264 + AAC).

Usage: /zulip-video <input-file>

Run the `ffmpeg` command to convert the input file to a browser-compatible MP4.
Use these settings optimized for screen recordings with text:

- `-c:v libx264 -crf 23 -preset slow -tune animation` for sharp text on flat backgrounds
- `-vf "format=yuv420p"` for browser compatibility
- `-c:a aac -b:a 128k` for audio

Output the file next to the input with a `.mp4` extension. If the input is
already `.mp4`, suffix with `-zulip.mp4`.

The argument $ARGUMENTS is the path to the input video file.
