/* async_mutex.vala
 *
 * Copyright 2022 Fyra Labs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class AsyncMutex {
    private class Callback {
        public SourceFunc callback;

        public Callback (owned SourceFunc cb) {
            callback = (owned)cb;
        }
    }

    private Gee.ArrayQueue<Callback> callbacks;
    private bool locked;

    public AsyncMutex () {
        locked = false;
        callbacks = new Gee.ArrayQueue<Callback> ();
    }

    public async void lock () {
        while (locked) {
            SourceFunc cb = lock.callback;
            callbacks.offer_head (new Callback ((owned)cb));
            yield;
        }

        locked = true;
    }

    public void unlock () {
        locked = false;
        var callback = callbacks.poll_head ();
        if (callback != null) {
            Idle.add ((owned)callback.callback);
        }
    }
}
