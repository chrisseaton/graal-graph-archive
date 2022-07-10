import java.util.Random;

class Example {

    private final static Random RANDOM = new Random();

    public static void main(String[] args) {
        if (args.length != 0) {
            throw new UnsupportedOperationException("not expecting any arguments");
        }

        while (true) {
            example(RANDOM.nextInt(), RANDOM.nextInt());
        }
    }

    private static int example(int x, int y) {
        int a = x + y;
        opaqueCall();
        return a * 2 + a;
    }

    private static void opaqueCall() {
        /*
         * If we don't have some significant logic in here,
         * -XX:CompileCommand=dontinline,*::* won't help us as it'll be
         * considered trivial and inlined anyway.
         */
        RANDOM.nextInt();
    }

}
