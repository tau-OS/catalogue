/* services/thread_service.vala
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

delegate void WorkerFunc ();
delegate G ThreadFunc<G> () throws Error;


[Compact (opaque = true)]
class Worker {
    WorkerFunc func;

    public Worker (owned WorkerFunc func) {
        this.func = (owned) func;
    }

    public void run () {
        func ();
    }
}

namespace ThreadService {
    Once<ThreadPool<Worker>> _once;

    unowned ThreadPool<Worker> _get_thread_pool () throws ThreadError {
        return _once.once (() => {
            ThreadPool<Worker>? pool = null;
            try {
                pool = new ThreadPool<Worker>.with_owned_data (worker => worker.run (), 1, false);
            } catch (ThreadError e) {
                critical ("Error creating ThreadPool");
            }
            return pool;
        });
    }

    async G run_in_thread<G> (owned ThreadFunc<G> func) throws Error, ThreadError {
        unowned ThreadPool<Worker> thread_pool;
        try {
            thread_pool = _get_thread_pool ();
        } catch (ThreadError e) {
            throw e;
        }

        G result = null;
        Error? error = null;

        thread_pool.add (new Worker (() => {
            try {
                result = func ();
            } catch (Error e) {
                error = e;
            }

            Idle.add (run_in_thread.callback);
        }));

        yield;

        if (error != null) {
            throw error;
        }

        return result;
    }
}
