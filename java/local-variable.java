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
        return a * 2 + a;
    }

}
